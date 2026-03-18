import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/events/domain/entities/event_entity.dart';

/// Rotating gradient palette for event cards based on list index.
const _cardGradients = [
  [Color(0xFF22C55E), Color(0xFF10B981)],
  [Color(0xFF3B82F6), Color(0xFF6366F1)],
  [Color(0xFFF59E0B), Color(0xFFEF4444)],
  [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  [Color(0xFFEC4899), Color(0xFFEF4444)],
  [Color(0xFF06B6D4), Color(0xFF3B82F6)],
];

/// Tappable card displaying an event summary.
/// Shows gradient header with icon, title, description, date range,
/// and status badge.
class ExhibitionCard extends StatelessWidget {
  const ExhibitionCard({
    required this.event,
    required this.onTap,
    this.index = 0,
    super.key,
  });

  final EventEntity event;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGradientHeader(),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientHeader() {
    final colors = _cardGradients[index % _cardGradients.length];
    // Use the first letter of the title as a visual identifier
    final initial = event.title.isNotEmpty ? event.title[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Row(
        children: [
          // Letter avatar instead of emoji
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (event.startAt != null && event.endAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDateRange(),
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStat(Icons.event_outlined, _statusLabel()),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: AppColors.textHint,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final (label, color) = _statusInfo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.status == EventStatus.open ||
              event.status == EventStatus.voting) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textHint,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Maps EventStatus to a display label and badge color.
  (String, Color) _statusInfo() {
    switch (event.status) {
      case EventStatus.open:
      case EventStatus.voting:
        return ('Live', const Color(0xFF22C55E));
      case EventStatus.draft:
        return ('Upcoming', const Color(0xFF3B82F6));
      case EventStatus.closed:
      case EventStatus.archived:
        return ('Ended', const Color(0xFF9CA3AF));
    }
  }

  String _statusLabel() {
    switch (event.status) {
      case EventStatus.open:
        return 'Open for submissions';
      case EventStatus.voting:
        return 'Voting in progress';
      case EventStatus.draft:
        return 'Coming soon';
      case EventStatus.closed:
        return 'Event closed';
      case EventStatus.archived:
        return 'Archived';
    }
  }

  String _formatDateRange() {
    final start = _formatDate(event.startAt!);
    final end = _formatDate(event.endAt!);
    return '$start - $end';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
