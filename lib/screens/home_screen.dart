import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/chat_provider.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Navigation
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Hamburger
                  IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu, color: Color(0xFF1A1A1A)),
                    tooltip: 'Menu',
                  ),

                  // Center: Branding
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF8B7FD6),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Shiksha AI',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),

                  // Right: New Chat + Profile
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          ref.read(chatProvider.notifier).startNewChat();
                          Navigator.pushNamed(context, '/chat');
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF8B7FD6),
                              style: BorderStyle.none,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Color(0xFF8B7FD6),
                            size: 20,
                          ),
                        ),
                        tooltip: 'New Chat',
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/profile_setup'),
                        icon: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFE5E7EB),
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ),
                        tooltip: 'Profile',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // 2. Greeting Section
                    // Central Sparkle Icon Hero
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B7FD6), // Light Violet
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x338B7FD6),
                            blurRadius: 30,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Greeting Text
                    FutureBuilder<SharedPreferences>(
                      future: SharedPreferences.getInstance(),
                      builder: (context, snapshot) {
                        final name =
                            snapshot.data?.getString('user_name') ?? 'Student';
                        return Column(
                          children: [
                            Text(
                              'Hello, $name!',
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'How can I help you today?',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: const Color(0xFF4B5563),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // 3. Suggested Topics (2x2 Grid)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'SUGGESTED TOPICS',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _QuickActionCard(
                          icon: Icons.checklist,
                          label: 'Help with\nHomework',
                          color: const Color(0xFFF3E8FF),
                          iconColor: const Color(0xFF8B7FD6),
                          onTap: () => _navigateToChat(
                            context,
                            ref,
                            'Help with Homework: ',
                          ),
                        ),
                        _QuickActionCard(
                          icon: Icons.lightbulb,
                          label: 'Explain a\nConcept',
                          color: const Color(0xFFE0F2FE),
                          iconColor: const Color(0xFF0284C7),
                          onTap: () => _navigateToChat(
                            context,
                            ref,
                            'Explain a Concept: ',
                          ),
                        ),
                        _QuickActionCard(
                          icon: Icons.quiz_outlined,
                          label: 'Practice\nQuestions',
                          color: const Color(0xFFDCFCE7),
                          iconColor: const Color(0xFF16A34A),
                          onTap: () => _navigateToChat(
                            context,
                            ref,
                            'Practice Questions: ',
                          ),
                        ),
                        _QuickActionCard(
                          icon: Icons.school,
                          label: 'Study\nTips',
                          color: const Color(0xFFFFEDD5),
                          iconColor: const Color(0xFFEA580C),
                          onTap: () =>
                              _navigateToChat(context, ref, 'Study Tips: '),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // 4. Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: () {
                          ref.read(chatProvider.notifier).startNewChat();
                          Navigator.pushNamed(context, '/chat');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF8B7FD6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 4,
                          shadowColor: const Color(
                            0xFF8B7FD6,
                          ).withValues(alpha: 0.4),
                          textStyle: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Start New Chat'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Offline Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Privacy First • Offline Access',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChat(
    BuildContext context,
    WidgetRef ref,
    String initialText,
  ) {
    ref.read(chatProvider.notifier).startNewChat();
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {'initialText': initialText},
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
