import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Page showing all comments received on the user's projects.
/// Each card displays commenter info, which project, the comment text,
/// a timestamp, and a read/unread indicator.
class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  int _selectedTab = 0;
  final List<String> _tabs = const ['All', 'Unread', 'Read'];

  List<_DemoComment> get _filteredComments {
    switch (_selectedTab) {
      case 1:
        return _demoComments.where((c) => !c.isRead).toList();
      case 2:
        return _demoComments.where((c) => c.isRead).toList();
      default:
        return _demoComments;
    }
  }

  int get _unreadCount =>
      _demoComments.where((c) => !c.isRead).length;

  void _markAsRead(_DemoComment comment) {
    if (!comment.isRead) {
      setState(() => comment.isRead = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: CenteredContent(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              _buildTabBar(context),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: _buildCommentsList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, AppSpacing.md, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comments',
                  style: AppTypography.h2.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  '$_unreadCount unread',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Mark all as read button
          GestureDetector(
            onTap: () {
              setState(() {
                for (final c in _demoComments) {
                  c.isRead = true;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                'Mark all read',
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    const activeColor = Color(0xFF1A1D2E);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isActive = _selectedTab == i;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? Colors.white
                          : context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context) {
    final comments = _filteredComments;

    if (comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 56,
              color: context.colors.textHint.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No comments here',
              style: AppTypography.bodyLarge.copyWith(
                color: context.colors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return _CommentCard(
          comment: comments[index],
          onTap: () => _markAsRead(comments[index]),
        );
      },
    );
  }
}

// -- Comment card widget --

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment, required this.onTap});

  final _DemoComment comment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          // Subtle left accent for unread comments
          border: !comment.isRead
              ? Border(
                  left: BorderSide(color: context.colors.primary, width: 3),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopRow(context),
            const SizedBox(height: 10),
            _buildCommentBody(context),
            const SizedBox(height: 10),
            _buildProjectTag(context),
          ],
        ),
      ),
    );
  }

  /// Commenter avatar, name, time, and unread dot
  Widget _buildTopRow(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: comment.avatarColors),
          ),
          child: Center(
            child: Text(
              comment.authorInitial,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Name and time
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.authorName,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                comment.timeAgo,
                style: AppTypography.caption.copyWith(
                  color: context.colors.textHint,
                ),
              ),
            ],
          ),
        ),
        // Unread indicator
        if (!comment.isRead)
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildCommentBody(BuildContext context) {
    return Text(
      comment.text,
      style: AppTypography.bodyMedium.copyWith(
        color: context.colors.textPrimary,
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Shows which project this comment belongs to
  Widget _buildProjectTag(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            comment.projectEmoji,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              comment.projectName,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// -- Demo data --

class _DemoComment {
  _DemoComment({
    required this.authorName,
    required this.authorInitial,
    required this.avatarColors,
    required this.text,
    required this.projectName,
    required this.projectEmoji,
    required this.timeAgo,
    this.isRead = false,
  });

  final String authorName;
  final String authorInitial;
  final List<Color> avatarColors;
  final String text;
  final String projectName;
  final String projectEmoji;
  final String timeAgo;
  bool isRead;
}

final List<_DemoComment> _demoComments = [
  _DemoComment(
    authorName: 'Sara Hassan',
    authorInitial: 'S',
    avatarColors: const [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    text:
        'This is an amazing project! The AI scheduling feature '
        'is really well thought out. Would love to see it integrated '
        'with Google Calendar.',
    projectName: 'NeuroSync Assistant',
    projectEmoji: '\u{1F916}',
    timeAgo: '2 hours ago',
  ),
  _DemoComment(
    authorName: 'Omar Jamal',
    authorInitial: 'O',
    avatarColors: const [Color(0xFF22C55E), Color(0xFF10B981)],
    text:
        'Great work on the IoT sensors. How does it handle '
        'real-time data streaming with multiple nodes?',
    projectName: 'EcoSmart Dashboard',
    projectEmoji: '\u{1F33F}',
    timeAgo: '5 hours ago',
  ),
  _DemoComment(
    authorName: 'Fatima Zain',
    authorInitial: 'F',
    avatarColors: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
    text: 'The peer-to-peer matching algorithm is clever. Voted!',
    projectName: 'StudyHub Platform',
    projectEmoji: '\u{1F310}',
    timeAgo: '1 day ago',
    isRead: true,
  ),
  _DemoComment(
    authorName: 'Ali Mohammed',
    authorInitial: 'A',
    avatarColors: const [Color(0xFF3B82F6), Color(0xFF6366F1)],
    text:
        'Love the AR concept for campus exploration. '
        'Have you tested it on older devices? '
        'Performance might be a concern.',
    projectName: 'Campus Quest AR',
    projectEmoji: '\u{1F3AE}',
    timeAgo: '2 days ago',
    isRead: true,
  ),
  _DemoComment(
    authorName: 'Noor Kareem',
    authorInitial: 'N',
    avatarColors: const [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
    text:
        'The meal planning feature is exactly what campus '
        'students need. Can it integrate with the cafeteria menu?',
    projectName: 'MealMind AI',
    projectEmoji: '\u{1F37D}\u{FE0F}',
    timeAgo: '3 days ago',
  ),
  _DemoComment(
    authorName: 'Khalid Omer',
    authorInitial: 'K',
    avatarColors: const [Color(0xFFEF4444), Color(0xFFF97316)],
    text:
        'Really useful analytics dashboard. The grade prediction '
        'model seems accurate based on the demo.',
    projectName: 'GradeFlow Analytics',
    projectEmoji: '\u{1F4CA}',
    timeAgo: '4 days ago',
    isRead: true,
  ),
];
