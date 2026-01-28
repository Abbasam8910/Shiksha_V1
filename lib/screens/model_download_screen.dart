import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/download_provider.dart';

class ModelDownloadScreen extends ConsumerStatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  ConsumerState<ModelDownloadScreen> createState() =>
      _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends ConsumerState<ModelDownloadScreen> {
  // Removed auto-start in initState as per new requirements (Manual Trigger)

  // Helper handle exit
  Future<void> _showExitDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Exit Setup?',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'The download is required to use the app. Are you sure you want to stop?',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Stay',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B7FD6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              SystemNavigator.pop(); // Exit app
            },
            child: Text(
              'Exit',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(downloadProgressProvider);
    final isDownloading = ref.watch(isDownloadingProvider);
    final error = ref.watch(downloadErrorProvider);
    final isReady = ref.watch(isModelReadyProvider);
    final speed = ref.watch(downloadSpeedProvider);
    final downloadedBytes = ref.watch(downloadedBytesProvider);
    final totalBytes = ref.watch(totalBytesProvider);

    // Auto-navigate if ready (and not just starting)
    // We check if progress > 0 to ensure we don't skip if it was already ready from before?
    // Actually, user wants "Success Trigger... automatically navigate".
    // If we land here and it's already ready, we should probably just navigate.
    if (isReady && !isDownloading && error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/profile_setup');
      });
    }

    // Helper to format bytes
    String formatBytes(int bytes) {
      if (bytes <= 0) return "0 MB";
      const int mb = 1024 * 1024;
      return "${(bytes / mb).toStringAsFixed(1)}MB";
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Layout
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _showExitDialog,
                ),
              ),
              Text(
                'SETUP',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 48),

              // Central Icon (Sparkle/Rocket proxy)
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0FF), // Lightest violet
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B7FD6).withValues(alpha: 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome, // Sparkles
                      size: 60,
                      color: Color(0xFF8B7FD6),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B7FD6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Text(
                'One Step Ahead in\nYour Learning\nJourney',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Download your personalized learning assistant and start mastering your subjects today.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Logic Switch: Error vs Button vs Progress
              if (error != null) ...[
                Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ref
                          .read(downloadControllerProvider.notifier)
                          .startDownload();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Download'),
                  ),
                ),
              ] else if (!isDownloading && !isReady) ...[
                // Initial State: Show Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ref
                          .read(downloadControllerProvider.notifier)
                          .startDownload();
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download Knowledge Base'),
                  ),
                ),
              ] else ...[
                // Progress Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top Row: Status + Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8B7FD6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(progress * 100).toInt()}% READY', // e.g. 65% READY
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF8B7FD6),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${formatBytes(downloadedBytes)}/${formatBytes(totalBytes)}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: const Color(0xFFF3F0FF),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF8B7FD6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Divider(color: Colors.grey[200], height: 1),
                      const SizedBox(height: 16),

                      // Bottom Row: Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL SIZE',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.sd_storage_rounded,
                                    size: 14,
                                    color: Color(0xFF8B7FD6),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formatBytes(totalBytes),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'DOWNLOAD SPEED',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    speed,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.speed_rounded,
                                    size: 14,
                                    color: Color(0xFF8B7FD6),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              Text(
                'YOUR OFFLINE AI TUTOR',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: Colors.grey[400],
                ),
              ),

              const SizedBox(height: 8),
              // Little bar at bottom
              Container(
                width: 140,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
