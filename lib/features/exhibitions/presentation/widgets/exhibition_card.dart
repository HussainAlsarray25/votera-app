import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/events/domain/entities/event_entity.dart';

/// Gradient palette for the card header, cycled by list index.
const _cardGradients = [
  [Color(0xFF3B82F6), Color(0xFF6366F1)],
  [Color(0xFF22C55E), Color(0xFF10B981)],
  [Color(0xFFF59E0B), Color(0xFFEF4444)],
  [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  [Color(0xFF06B6D4), Color(0xFF3B82F6)],
  [Color(0xFFEC4899), Color(0xFFEF4444)],
];

/// Tappable card displaying an event summary on the home screen.
///
/// Layout:
///   - Gradient header with decorative shapes, status badge, title, and dates
///   - White body with description
///   - Metadata footer with phase info, team size, and navigation arrow
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

  List<Color> get _gradientColors =>
      _cardGradients[index % _cardGradients.length];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: _gradientColors.first.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GradientHeader(
                  colors: _gradientColors,
                  event: event,
                ),
                _CardBody(event: event),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -- Gradient Header ----------------------------------------------------------

/// Colourful top section with decorative floating circles,
/// status badge, title, and date range.
class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.colors, required this.event});

  final List<Color> colors;
  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles for visual depth
          ..._buildDecorations(),
          // Foreground content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBadge(status: event.status),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (event.startAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDateRange(),
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Semi-transparent decorative circles positioned at the top-right corner.
  List<Widget> _buildDecorations() {
    return [
      const Positioned(
        top: -18,
        right: -12,
        child: _Circle(size: 72, opacity: 0.08),
      ),
      const Positioned(
        top: 10,
        right: 28,
        child: _Circle(size: 40, opacity: 0.1),
      ),
      const Positioned(
        bottom: -10,
        right: 60,
        child: _Circle(size: 24, opacity: 0.06),
      ),
    ];
  }

  String _formatDateRange() {
    final start = _shortDate(event.startAt!);
    if (event.endAt == null) return start;
    return '$start - ${_shortDate(event.endAt!)}';
  }

  static String _shortDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}';
  }
}

/// Small semi-transparent white circle used as a decorative element.
class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

// -- Status Badge -------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, dotColor) = _labelAndDot();
    final isActive =
        status == EventStatus.open || status == EventStatus.voting;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
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
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _labelAndDot() {
    switch (status) {
      case EventStatus.open:
        return ('Open', const Color(0xFFBBF7D0));
      case EventStatus.voting:
        return ('Voting', const Color(0xFFFDE68A));
      case EventStatus.draft:
        return ('Upcoming', Colors.white);
      case EventStatus.closed:
        return ('Closed', Colors.white);
      case EventStatus.archived:
        return ('Archived', Colors.white);
    }
  }
}

// -- Card Body ----------------------------------------------------------------

/// White section below the header containing description and metadata.
class _CardBody extends StatelessWidget {
  const _CardBody({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          _MetadataRow(event: event),
        ],
      ),
    );
  }
}

// -- Metadata Row -------------------------------------------------------------

/// Footer row showing phase, optional team size, and a forward arrow.
class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPhaseChip(),
        if (_hasTeamInfo()) ...[
          _dot(),
          _buildTeamChip(),
        ],
        if (event.status == EventStatus.voting &&
            event.maxCommunityVotes != null) ...[
          _dot(),
          _iconLabel(
            Icons.how_to_vote_outlined,
            '${event.maxCommunityVotes} votes',
          ),
        ],
        const Spacer(),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseChip() {
    final (icon, label, color) = _phaseInfo();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamChip() {
    return _iconLabel(Icons.group_outlined, _teamLabel());
  }

  Widget _iconLabel(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Small separator dot between metadata items.
  Widget _dot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  bool _hasTeamInfo() =>
      event.minTeamSize != null || event.maxTeamSize != null;

  String _teamLabel() {
    final min = event.minTeamSize;
    final max = event.maxTeamSize;
    if (min != null && max != null) return '$min-$max members';
    if (min != null) return '$min+ members';
    if (max != null) return 'Up to $max';
    return '';
  }

  /// Returns (icon, label, color) for the current event phase.
  (IconData, String, Color) _phaseInfo() {
    switch (event.status) {
      case EventStatus.open:
        return (
          Icons.edit_note_rounded,
          'Submissions open',
          const Color(0xFF16A34A),
        );
      case EventStatus.voting:
        return (
          Icons.how_to_vote_rounded,
          'Vote now',
          const Color(0xFF7C3AED),
        );
      case EventStatus.draft:
        return (
          Icons.schedule_rounded,
          'Coming soon',
          AppColors.primary,
        );
      case EventStatus.closed:
        return (
          Icons.check_circle_outline_rounded,
          'Ended',
          AppColors.textHint,
        );
      case EventStatus.archived:
        return (
          Icons.inventory_2_outlined,
          'Archived',
          AppColors.textHint,
        );
    }
  }
}
