import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/model_download_service.dart';

final modelDownloadServiceProvider = Provider((ref) => ModelDownloadService());

final downloadProgressProvider = StateProvider<double>((ref) => 0.0);
final isDownloadingProvider = StateProvider<bool>((ref) => false);
final downloadErrorProvider = StateProvider<String?>((ref) => null);
final isModelReadyProvider = StateProvider<bool>((ref) => false);
final downloadedBytesProvider = StateProvider<int>((ref) => 0);
final totalBytesProvider = StateProvider<int>((ref) => 0);
final downloadSpeedProvider = StateProvider<String>(
  (ref) => "0.0 MB/s",
); // New provider

class DownloadNotifier extends StateNotifier<void> {
  final ModelDownloadService _service;
  final Ref _ref;

  DownloadNotifier(this._service, this._ref) : super(null) {
    checkModelStatus();
  }

  Future<void> checkModelStatus() async {
    final exists = await _service.isModelDownloaded();
    _ref.read(isModelReadyProvider.notifier).state = exists;
  }

  Future<void> startDownload() async {
    // Check if already downloaded
    if (await _service.isModelDownloaded()) {
      _ref.read(isModelReadyProvider.notifier).state = true;
      return;
    }

    try {
      _ref.read(isDownloadingProvider.notifier).state = true;
      _ref.read(downloadErrorProvider.notifier).state = null;
      _ref.read(downloadProgressProvider.notifier).state = 0.0;
      _ref.read(downloadSpeedProvider.notifier).state = "0.0 MB/s";
      _ref.read(downloadedBytesProvider.notifier).state = 0;
      _ref.read(totalBytesProvider.notifier).state = 0;

      int lastReceived = 0;
      DateTime lastTime = DateTime.now();

      await _service.downloadModel(
        onProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _ref.read(downloadProgressProvider.notifier).state = progress;
            _ref.read(downloadedBytesProvider.notifier).state = received;
            _ref.read(totalBytesProvider.notifier).state = total;

            // Calculate Speed
            final now = DateTime.now();
            final difference = now.difference(lastTime).inMilliseconds;
            if (difference > 500) {
              // Update every 500ms
              final bytesDelta = received - lastReceived;
              final speedBytesPerSec = (bytesDelta * 1000) / difference;
              final speedMbPerSec = speedBytesPerSec / (1024 * 1024);

              _ref.read(downloadSpeedProvider.notifier).state =
                  "${speedMbPerSec.toStringAsFixed(1)} MB/s";

              lastReceived = received;
              lastTime = now;
            }
          }
        },
      );

      _ref.read(isModelReadyProvider.notifier).state = true;
    } catch (e) {
      _ref.read(downloadErrorProvider.notifier).state = e.toString();
    } finally {
      _ref.read(isDownloadingProvider.notifier).state = false;
    }
  }

  void cancelDownload() {
    _service.cancelDownload();
    _ref.read(isDownloadingProvider.notifier).state = false;
    _ref.read(downloadProgressProvider.notifier).state = 0.0;
  }
}

final downloadControllerProvider =
    StateNotifierProvider<DownloadNotifier, void>((ref) {
      final service = ref.watch(modelDownloadServiceProvider);
      return DownloadNotifier(service, ref);
    });
