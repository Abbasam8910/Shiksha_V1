import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/llm_service.dart';
import 'download_provider.dart';

final chatBoxProvider = Provider<Box<ChatSession>>((ref) {
  throw UnimplementedError('chatBoxProvider not initialized');
});

final llmServiceProvider = Provider<LLMService>((ref) {
  final downloadService = ref.watch(modelDownloadServiceProvider);
  return LLMService(downloadService);
});

final currentSessionIdProvider = StateProvider<String?>((ref) => null);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Box<ChatSession> _box;
  final LLMService _llmService;
  final Ref _ref;
  StreamSubscription<String>? _currentInferenceSubscription;

  ChatNotifier(this._box, this._llmService, this._ref) : super([]);

  Future<void> loadSession(String sessionId) async {
    final session = _box.get(sessionId);
    if (session != null) {
      state = session.messages;
      _ref.read(currentSessionIdProvider.notifier).state = sessionId;
    }
  }

  Future<void> startNewChat() async {
    state = [];
    _ref.read(currentSessionIdProvider.notifier).state = null;

    // Ensure model is loaded when starting a chat
    if (!_llmService.isLoaded) {
      try {
        await _llmService.loadModel();
      } catch (e) {
        print('Error loading model on new chat: $e');
      }
    }
  }

  Future<void> addMessage(String content, String role) async {
    // 1. Add User Message
    final userMessage = ChatMessage(
      role: role,
      content: content,
      timestamp: DateTime.now(),
    );
    state = [...state, userMessage];
    await _saveToHive();

    if (role == 'user') {
      // 2. Prepare for AI Response
      // Ensure model is loaded
      if (!_llmService.isLoaded) {
        try {
          print('🔄 Loading model for first time...');
          await _llmService.loadModel();
        } catch (e) {
          _addErrorMessage('Failed to load AI model: $e');
          return;
        }
      }

      // Create a placeholder assistant message
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: '...', // Show thinking indicator
        timestamp: DateTime.now(),
      );
      state = [...state, assistantMessage];

      // Cancel any previous inference stream
      print('🛑 [PROVIDER] Canceling previous stream...');
      await _currentInferenceSubscription?.cancel();
      _currentInferenceSubscription = null;

      // CRITICAL: Cancel generation in the service to reset _isGenerating flag
      _llmService.cancelGeneration();
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Give service time to reset

      // Stream Response (non-blocking)
      String fullResponse = '';
      int tokenCount = 0;

      // Listen to the stream from managed isolate (non-blocking!)
      print('📡 [PROVIDER] Starting stream for: "$content"');
      final stream = _llmService.streamResponse(content);
      _currentInferenceSubscription = stream.listen(
        (token) {
          fullResponse += token;
          tokenCount++;

          // Debug: Log each token
          if (tokenCount <= 5) {
            print('🔍 Token $tokenCount: "$token"');
          }

          // Update UI on EVERY token for smooth streaming
          final updatedMessages = List<ChatMessage>.from(state);
          if (updatedMessages.isNotEmpty) {
            updatedMessages.last = ChatMessage(
              role: 'assistant',
              content: fullResponse,
              timestamp: DateTime.now(),
            );
            state = updatedMessages;
          }
        },
        onDone: () async {
          // Final update with complete response
          final updatedMessages = List<ChatMessage>.from(state);
          if (updatedMessages.isNotEmpty) {
            updatedMessages.last = ChatMessage(
              role: 'assistant',
              content: fullResponse.isEmpty
                  ? 'No response generated.'
                  : fullResponse,
              timestamp: DateTime.now(),
            );
            state = updatedMessages;
          }

          // Save final state to Hive
          await _saveToHive();
          _currentInferenceSubscription = null;
        },
        onError: (e, stackTrace) {
          print('❌ Error generating response: $e');
          _addErrorMessage('Error generating response: $e');
          _currentInferenceSubscription = null;
        },
      );
    }
  }

  String _generateSmartTitle(String message) {
    // Remove common question words and extract key content
    String cleaned = message.toLowerCase();

    // Remove question words
    final questionWords = [
      'what is',
      'what are',
      'how to',
      'how do',
      'why',
      'when',
      'where',
      'who',
      'explain',
      'tell me about',
      'help me with',
      'can you',
    ];
    for (var word in questionWords) {
      cleaned = cleaned.replaceAll(word, '').trim();
    }

    // Remove punctuation
    cleaned = cleaned.replaceAll(RegExp(r'[?!.,]'), '');

    // Capitalize first letter of each word
    final words = cleaned.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) {
      return message.length > 30 ? '${message.substring(0, 30)}...' : message;
    }

    // Take first 3-4 meaningful words
    final titleWords = words
        .take(4)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .toList();
    return titleWords.join(' ');
  }

  void deleteSession(String sessionId) {
    // Delete from Hive storage
    _box.delete(sessionId);

    // If this was the current session, clear it
    if (_ref.read(currentSessionIdProvider) == sessionId) {
      state = [];
      _ref.read(currentSessionIdProvider.notifier).state = null;
    }
  }

  Future<void> clearAllChats() async {
    // Clear all sessions from Hive
    await _box.clear();

    // Clear current state
    state = [];
    _ref.read(currentSessionIdProvider.notifier).state = null;

    // Reset context
    await _llmService.resetContext();
  }

  void _addErrorMessage(String error) {
    final errorMessage = ChatMessage(
      role: 'assistant',
      content: 'Error: $error',
      timestamp: DateTime.now(),
    );
    state = [...state, errorMessage];
    _saveToHive();
  }

  Future<void> _saveToHive() async {
    final sessionId = _ref.read(currentSessionIdProvider);
    if (sessionId == null) {
      // Create new session
      final newId = const Uuid().v4();

      // Auto-generate smart title from first USER message
      String title = 'New Chat';
      if (state.isNotEmpty) {
        // Find first user message
        final userMessages = state.where((m) => m.role == 'user');
        if (userMessages.isNotEmpty) {
          title = _generateSmartTitle(userMessages.first.content);
        }
      }

      final newSession = ChatSession(
        id: newId,
        title: title,
        messages: state,
        lastUpdated: DateTime.now(),
      );
      await _box.put(newId, newSession);
      _ref.read(currentSessionIdProvider.notifier).state = newId;
    } else {
      // Update existing session
      final session = _box.get(sessionId);
      if (session != null) {
        // Create new session object to force update
        final updatedSession = ChatSession(
          id: session.id,
          title: session.title,
          messages: state,
          lastUpdated: DateTime.now(),
        );
        await _box.put(sessionId, updatedSession);
      }
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((
  ref,
) {
  final box = ref.watch(chatBoxProvider);
  final llmService = ref.watch(llmServiceProvider);
  return ChatNotifier(box, llmService, ref);
});

// This provider watches the box and updates when it changes
final chatSessionsProvider = Provider<List<ChatSession>>((ref) {
  final box = ref.watch(chatBoxProvider);
  // Force rebuild by watching the box
  ref.watch(chatProvider); // This ensures updates when chats change
  return box.values.toList()
    ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
});
