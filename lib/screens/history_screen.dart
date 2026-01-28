import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chat_provider.dart';
import '../models/chat_session.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allSessions = ref.watch(chatSessionsProvider);
    final filteredSessions = allSessions.where((session) {
      final matchesQuery = session.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesQuery;
    }).toList();

    // Sort sessions by date descending
    final sortedSessions = List<ChatSession>.from(filteredSessions)
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

    // Group items
    final groupedItems = <dynamic>[];
    String? lastHeader;

    for (var session in sortedSessions) {
      final header = _getDateHeader(session.lastUpdated);
      if (header != lastHeader) {
        groupedItems.add(header);
        lastHeader = header;
      }
      groupedItems.add(session);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Conversation History',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF3E8FF)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              size: 16,
                              color: Color(0xFF8B7FD6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'OFFLINE',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF8B7FD6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your learning journey so far',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search topics...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Color(0xFF8B7FD6),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: groupedItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_edu,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations found',
                            style: GoogleFonts.inter(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: groupedItems.length,
                      itemBuilder: (context, index) {
                        final item = groupedItems[index];
                        if (item is String) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 12),
                            child: Text(
                              item,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                                letterSpacing: 1.0,
                              ),
                            ),
                          );
                        } else if (item is ChatSession) {
                          return _buildHistoryCard(context, item, ref);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(chatProvider.notifier).startNewChat();
          Navigator.of(context).pushNamed('/chat');
        },
        backgroundColor: const Color(0xFF8B7FD6),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    ChatSession session,
    WidgetRef ref,
  ) {
    final subjectStyle = _getSubjectStyle(session.subject);
    final lastMessage = session.messages.isNotEmpty
        ? session.messages.last.content
        : 'No messages yet';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          onTap: () {
            ref.read(chatProvider.notifier).loadSession(session.id);
            Navigator.of(context).pushNamed('/chat');
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 3,
                  height: 40,
                  decoration: BoxDecoration(
                    color: subjectStyle.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: subjectStyle.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    subjectStyle.icon,
                    color: subjectStyle.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessage.replaceAll('\n', ' '),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _SubjectStyle _getSubjectStyle(String? subject) {
    switch (subject?.toLowerCase()) {
      case 'math':
      case 'mathematics':
        return _SubjectStyle(
          icon: Icons.calculate_outlined,
          color: Colors.orange,
          bgColor: Colors.orange.withValues(alpha: 0.1),
        );
      case 'science':
      case 'physics':
      case 'chemistry':
      case 'biology':
        return _SubjectStyle(
          icon: Icons.science_outlined,
          color: Colors.green,
          bgColor: Colors.green.withValues(alpha: 0.1),
        );
      case 'english':
      case 'literature':
        return _SubjectStyle(
          icon: Icons.edit_note,
          color: Colors.blue,
          bgColor: Colors.blue.withValues(alpha: 0.1),
        );
      case 'history':
      case 'social studies':
        return _SubjectStyle(
          icon: Icons.menu_book_rounded,
          color: Colors.purple,
          bgColor: Colors.purple.withValues(alpha: 0.1),
        );
      default:
        // Default style for unknown or general chats
        return _SubjectStyle(
          icon: Icons.auto_awesome,
          color: const Color(0xFF8B7FD6),
          bgColor: const Color(0xFFF3F0FF),
        );
    }
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0 && now.day == date.day) return "TODAY";
    if (difference == 1 || (difference == 0 && now.day != date.day)) {
      return "YESTERDAY";
    }
    if (difference < 7) return "LAST WEEK";
    return "OLDER";
  }
}

class _SubjectStyle {
  final IconData icon;
  final Color color;
  final Color bgColor;

  _SubjectStyle({
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}
