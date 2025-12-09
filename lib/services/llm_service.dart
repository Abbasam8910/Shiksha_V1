import 'dart:async';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'model_download_service.dart';

class LLMService {
  final ModelDownloadService _downloadService;

  LlamaParent? _llamaParent;
  StreamSubscription? _streamSubscription;
  bool _isInitialized = false;
  bool _isLoading = false;

  ChatHistory? _chatHistory;
  ChatMLFormat? _chatFormat;

  StreamController<String>? _currentResponseController;
  bool _isGenerating = false;

  LLMService(this._downloadService);

  bool get isLoaded => _isInitialized;

  Future<void> loadModel() async {
    if (_isInitialized) {
      print('Model already loaded, skipping...');
      return;
    }

    if (_isLoading) {
      print('Model is currently loading, waiting...');
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isLoading = true;

    try {
      print('🔄 Starting model load...');
      final modelPath = await _downloadService.getModelPath();
      print('📂 Model path: $modelPath');

      final loadCommand = LlamaLoad(
        path: modelPath,
        modelParams: ModelParams()
          ..nGpuLayers = 0
          ..useMemorymap = true
          ..useMemoryLock = false,
        contextParams: ContextParams()
          ..nCtx = 2048
          ..nThreads = 4
          ..nBatch = 512
          ..nPredict = 512,
        samplingParams: SamplerParams()
          ..temp = 0.7
          ..topP = 0.8
          ..topK = 40
          ..penaltyRepeat = 1.05,
        format: ChatMLFormat(),
      );

      _chatFormat = ChatMLFormat();
      _chatHistory = ChatHistory(keepRecentPairs: 10);

      _chatHistory!.addMessage(
        role: Role.system,
        content:
            'You are Qwen, created by Alibaba Cloud. You are a helpful assistant.',
      );

      print('🔧 Initializing LlamaParent...');
      _llamaParent = LlamaParent(loadCommand);
      await _llamaParent!.init();

      _streamSubscription = _llamaParent!.stream.listen(
        (token) {
          print(
            '🔹 [ISOLATE] Token: "${token.length > 20 ? token.substring(0, 20) : token}"',
          );
          if (_currentResponseController != null &&
              !_currentResponseController!.isClosed) {
            _currentResponseController!.add(token);
          }
        },
        onError: (error) {
          print('❌ [ISOLATE] Error: $error');
          if (_currentResponseController != null &&
              !_currentResponseController!.isClosed) {
            _currentResponseController!.addError(error);
            _currentResponseController!.close();
          }
          _isGenerating = false;
        },
        onDone: () {
          print('🏁 [ISOLATE] Stream completed!');
          if (_currentResponseController != null &&
              !_currentResponseController!.isClosed) {
            _currentResponseController!.close();
          }
          _isGenerating = false;
        },
      );

      _isInitialized = true;
      _isLoading = false;
      print('✅ Model loaded successfully');
    } catch (e) {
      print('❌ Error loading model: $e');
      _isInitialized = false;
      _isLoading = false;
      rethrow;
    }
  }

  // Cancel current generation and reset state
  void cancelGeneration() {
    print('🛑 [CANCEL] Canceling current generation');
    _currentResponseController?.close();
    _currentResponseController = null;
    _isGenerating = false;
  }

  Future<void> resetContext() async {
    // Wait for any ongoing generation to complete
    while (_isGenerating) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (_chatHistory != null) {
      print('🔄 [CONTEXT] Resetting chat history...');
      _chatHistory = ChatHistory(keepRecentPairs: 10);
      _chatHistory!.addMessage(
        role: Role.system,
        content:
            'You are Qwen, created by Alibaba Cloud. You are a helpful assistant.',
      );
      print('✅ [CONTEXT] Reset complete');
    }
  }

  Stream<String> streamResponse(String message) async* {
    print('🚀 [ENTRY] streamResponse called with: "$message"');
    print(
      '🔍 [STATE] _isInitialized: $_isInitialized, _isGenerating: $_isGenerating',
    );

    if (!_isInitialized ||
        _llamaParent == null ||
        _chatHistory == null ||
        _chatFormat == null) {
      print('❌ [ERROR] Model not loaded!');
      throw Exception('Model not loaded.');
    }

    // Wait for previous generation to complete with timeout
    int waitCount = 0;
    while (_isGenerating) {
      waitCount++;
      print('⏳ [$waitCount] Waiting for previous generation...');
      await Future.delayed(const Duration(milliseconds: 100));
      if (waitCount > 30) {
        // 3 second timeout
        print('⚠️ [TIMEOUT] Force canceling previous generation');
        cancelGeneration();
        await Future.delayed(const Duration(milliseconds: 100));
        break;
      }
    }

    _isGenerating = true;
    print('💬 [STREAM] Starting for: "$message"');

    // Add user message to history
    _chatHistory!.addMessage(role: Role.user, content: message);

    // Build the full conversation prompt using chat history
    final conversationMessages = _chatHistory!.messages
        .map((msg) => '${msg.role.name}: ${msg.content}')
        .join('\n');

    // Format prompt with ChatML format
    String formattedPrompt =
        '<|im_start|>system\n'
        'You are Qwen, created by Alibaba Cloud. You are a helpful assistant.\n'
        '<|im_end|>\n';

    // Add all previous messages
    for (var msg in _chatHistory!.messages) {
      if (msg.role != Role.system) {
        formattedPrompt +=
            '<|im_start|>${msg.role.name}\n${msg.content}\n<|im_end|>\n';
      }
    }

    // Add assistant start tag
    formattedPrompt += '<|im_start|>assistant\n';

    print('🔍 PROMPT:');
    print(formattedPrompt);
    print('---END---');

    // Close previous controller if exists
    if (_currentResponseController != null) {
      await _currentResponseController!.close();
    }

    print('🔄 [STREAM] Creating new controller...');
    _currentResponseController = StreamController<String>();
    print('✅ [STREAM] Controller created');

    print('📤 [STREAM] Sending to isolate...');
    _llamaParent!.sendPrompt(formattedPrompt);
    print('✅ [STREAM] Sent, waiting...');

    String fullResponse = '';
    int tokenCount = 0;
    Timer? timeoutTimer;

    // Auto-close stream if no tokens for 2 seconds
    void resetTimeout() {
      timeoutTimer?.cancel();
      timeoutTimer = Timer(const Duration(seconds: 2), () {
        print('⏱️ [TIMEOUT] No tokens for 2s, closing stream');
        _currentResponseController?.close();
      });
    }

    try {
      await for (final token in _currentResponseController!.stream) {
        tokenCount++;
        resetTimeout(); // Reset timeout on each token

        // Check for EOS token before processing
        if (token.contains('<|im_end|>')) {
          print('🏁 [STREAM] Found EOS token, stopping');
          timeoutTimer?.cancel();
          break;
        }

        fullResponse += token;

        if (tokenCount <= 5) {
          print('🔍 Token $tokenCount: "$token"');
        }

        yield token;
      }
    } catch (e) {
      print('❌ [STREAM] Error: $e');
      timeoutTimer?.cancel();
      _isGenerating = false;
      rethrow;
    }

    timeoutTimer?.cancel(); // Cleanup timer

    print(
      '✅ [STREAM] Complete. Tokens: $tokenCount, Response length: ${fullResponse.length}',
    );

    // Add assistant response to history (remove EOS token if present)
    final cleanResponse = fullResponse.replaceAll('<|im_end|>', '').trim();
    _chatHistory!.addMessage(role: Role.assistant, content: cleanResponse);

    _isGenerating = false;
  }

  void unloadModel() {
    _isGenerating = false;
    _currentResponseController?.close();
    _streamSubscription?.cancel();
    _llamaParent?.dispose();
    _llamaParent = null;
    _chatHistory = null;
    _chatFormat = null;
    _isInitialized = false;
  }
}
