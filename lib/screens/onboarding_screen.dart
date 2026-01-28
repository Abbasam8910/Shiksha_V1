import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Learn Anywhere,\nAnytime.',
      'body':
          'Your personal tutor that works entirely offline. No internet? No problem.',
      // Key 'type': 'offline' triggers the custom illustration
      'type': 'offline',
      'color': Color(0xFF8B7FD6),
    },
    {
      'title': 'Structure Your\nLearning Journey',
      'body':
          'Organize your study materials and keep track of your progress effortlessly.',
      'type': 'structure', // Updated type
      'color': Color(0xFF8B7FD6),
    },
    {
      'title': 'Interactive\nStudy Assistance',
      'body':
          'Get instant answers and explanations to your questions without waiting.',
      'type': 'interactive', // Updated type
      'color': Color(0xFF8B7FD6),
    },
    {
      'title': 'Your Private\nAI Tutor',
      'body':
          'Always ready to help with your studies, providing personalized guidance just for you.',
      'type': 'tutor',
      'color': Color(0xFF8B7FD6),
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, '/download');
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage == _pages.length - 1)
                    IconButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutQuart,
                        );
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )
                  else
                    const SizedBox(width: 48),

                  Text(
                    _currentPage == _pages.length - 1 ? 'AI TUTOR' : 'WELCOME',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),

                  // Help Button
                  TextButton.icon(
                    onPressed: () => _showHelpBottomSheet(context),
                    icon: Icon(
                      Icons.help_outline_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 20,
                    ),
                    label: Text(
                      'Help',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPageContent(_pages[index], screenHeight);
                },
              ),
            ),

            // Footer controls
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: screenHeight * 0.03), // Responsive spacing
                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ScaleButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Finish Setup'
                            : _currentPage == 0
                            ? 'Get Started'
                            : 'Next',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B7FD6).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF8B7FD6),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Need Help?',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'How does this work offline?',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The "brain" of the app is downloaded to your phone. Once set up, you can use it anywhere—even in the forest or at home without internet!',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.5,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Is it free?',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yes! After the first download, it won\'t consume your mobile data.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.5,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Got it, let\'s continue',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageContent(Map<String, dynamic> data, double screenHeight) {
    // Calculate responsive illustration height (max 320, min 200, typically 35% of screen)
    final illustrationHeight = (screenHeight * 0.35).clamp(200.0, 320.0);

    // Select illustration based on type
    Widget illustration;
    if (data['type'] == 'offline') {
      illustration = _buildOfflineIllustration();
    } else if (data['type'] == 'tutor') {
      illustration = _buildTutorIllustration();
    } else if (data['type'] == 'structure') {
      illustration = _buildStructureIllustration();
    } else if (data['type'] == 'interactive') {
      illustration = _buildInteractiveIllustration();
    } else {
      illustration = _buildGenericIllustration(data, illustrationHeight);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration Card
            Container(
              width: double.infinity,
              height: illustrationHeight,
              decoration: BoxDecoration(
                // Gradient-like subtle background if needed, or just white/dark
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFF3F5FF), // Very light violet tint
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: illustration,
              ),
            ),
            SizedBox(height: screenHeight * 0.04), // Responsive spacing

            Text(
              data['title'],
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildRichBody(data['body']),
          ],
        ),
      ),
    );
  }

  // Custom Widget to mimic the 'No Wifi' / Offline illustration from screenshot
  Widget _buildOfflineIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Soft Blob
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(
                0xFFD0C9FF,
              ).withValues(alpha: 0.3), // Soft Violet
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Main Card
        Container(
          width: 180,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skeleton Text Lines
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 8,
                      width: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      width: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // No Wifi Icon Circle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBFF), // Lightest violet
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xFF8B7FD6),
                  size: 32,
                ),
              ),

              const Spacer(),
              // Bottom Decoration
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B7FD6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Floating floating elements
        // Top Right Star/Sparkle
        Positioned(
          top: 60,
          right: 50,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF8B7FD6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B7FD6).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),

        // Bottom Left Book/Square
        Positioned(
          bottom: 50,
          left: 50,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF90CAF9), // Light Blue
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF90CAF9).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  // Illustration for "Structure Your Learning Journey"
  Widget _buildStructureIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Elements
        Positioned(
          top: 30,
          left: 40,
          child: Transform.rotate(
            angle: -0.2,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFC8E6C9), // Light Green
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          right: 40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFCCBC), // Light Orange
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Central Folder Card
        Container(
          width: 200,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              // Tab
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 20, top: 20),
                  width: 60,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B7FD6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Rows
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildFileRow(Colors.orange[100]!, "Mathematics"),
                      const SizedBox(height: 6), // Reduced to 6 for safety
                      _buildFileRow(Colors.blue[100]!, "Physics"),
                      const SizedBox(height: 6), // Reduced to 6 for safety
                      _buildFileRow(Colors.purple[100]!, "History"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Checkmark
        Positioned(
          right: 50,
          top: 60,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF00C853),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildFileRow(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.folder, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Container(
          height: 8,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  // Illustration for "Interactive Study Assistance"
  Widget _buildInteractiveIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Dots
        Positioned(
          top: 30,
          right: 60,
          child: CircleAvatar(
            radius: 6,
            backgroundColor: const Color(0xFF8B7FD6).withValues(alpha: 0.4),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 60,
          child: CircleAvatar(
            radius: 4,
            backgroundColor: const Color(0xFF8B7FD6).withValues(alpha: 0.4),
          ),
        ),

        // Chat Bubbles
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left Bubble (User)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 40, bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 20,
                      color: Color(0xFF8B7FD6),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 8,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right Bubble (AI)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(right: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7FD6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B7FD6).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 8,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTutorIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Blobs
        Positioned(
          top: 40,
          left: 40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF8E1D0).withValues(alpha: 0.5), // Peachish
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF8E1D0).withValues(alpha: 0.3),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),

        // Book Card
        Container(
          width: 180,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B7FD6).withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(10, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Purple Spine
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0C9FF),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Center Brain Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Color(0xFF8B7FD6),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Lines
                    Container(
                      height: 8,
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 8,
                      width: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Graduation Cap Badge (Top Right)
        Positioned(
          top: 40,
          right: 40,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFADEC9), // Peach
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.school,
                color: Color(0xFF5D4037),
                size: 32,
              ), // Brownish icon
            ),
          ),
        ),
      ],
    );
  }

  // Fallback for other screens
  Widget _buildGenericIllustration(Map<String, dynamic> data, double height) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF8B7FD6).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF8B7FD6).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Icon(data['icon'], size: height * 0.25, color: data['color']),
      ],
    );
  }

  // Helper to parse and highlight specific text
  Widget _buildRichBody(String text) {
    // Simple logic: check for keywords to highlight based on requirements
    // Screen 1: "entirely offline"
    // Screen 4: "personalized guidance"

    final List<TextSpan> spans = [];
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final styleBase = GoogleFonts.inter(
      fontSize: 16,
      color: isDark ? Colors.grey[400] : const Color(0xFF4A4A4A),
      height: 1.5,
    );
    final styleHighlight = GoogleFonts.inter(
      fontSize: 16,
      color: const Color(0xFF8B7FD6),
      fontWeight: FontWeight.w600,
      height: 1.5,
    );

    if (text.contains('entirely offline')) {
      final parts = text.split('entirely offline');
      spans.add(TextSpan(text: parts[0], style: styleBase));
      spans.add(TextSpan(text: 'entirely offline', style: styleHighlight));
      if (parts.length > 1) {
        spans.add(TextSpan(text: parts[1], style: styleBase));
      }
    } else if (text.contains('keep track of your progress')) {
      final parts = text.split('keep track of your progress');
      spans.add(TextSpan(text: parts[0], style: styleBase));
      spans.add(
        TextSpan(text: 'keep track of your progress', style: styleHighlight),
      );
      if (parts.length > 1) {
        spans.add(TextSpan(text: parts[1], style: styleBase));
      }
    } else if (text.contains('instant answers')) {
      final parts = text.split('instant answers');
      spans.add(TextSpan(text: parts[0], style: styleBase));
      spans.add(TextSpan(text: 'instant answers', style: styleHighlight));
      if (parts.length > 1) {
        spans.add(TextSpan(text: parts[1], style: styleBase));
      }
    } else if (text.contains('personalized guidance')) {
      final parts = text.split('personalized guidance');
      spans.add(TextSpan(text: parts[0], style: styleBase));
      spans.add(TextSpan(text: 'personalized guidance', style: styleHighlight));
      if (parts.length > 1) {
        spans.add(TextSpan(text: parts[1], style: styleBase));
      }
    } else {
      spans.add(TextSpan(text: text, style: styleBase));
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: spans),
    );
  }
}

// Custom Scale Button Wrapper
class ScaleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const ScaleButton({super.key, required this.onPressed, required this.child});

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FilledButton(
              onPressed: null, // We handle tap manually
              style: FilledButton.styleFrom(
                disabledBackgroundColor: Theme.of(
                  context,
                ).colorScheme.primary, // Keep color when "disabled"
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
