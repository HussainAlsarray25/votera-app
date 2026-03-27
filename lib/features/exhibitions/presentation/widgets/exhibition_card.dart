import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/events/domain/entities/event_entity.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

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
      padding: EdgeInsets.only(bottom: 20.r),
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
          color: context.colors.surface,
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
      padding: EdgeInsets.fromLTRB(20.r, 18.r, 20.r, 20.r),
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
              SizedBox(height: AppSpacing.sm),
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
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: AppSizes.iconXs,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    SizedBox(width: AppSpacing.xs),
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
      Positioned(
        top: -18.r,
        right: -12.r,
        child: _Circle(size: 72.r, opacity: 0.08),
      ),
      Positioned(
        top: 10.r,
        right: 28.r,
        child: _Circle(size: 40.r, opacity: 0.1),
      ),
      Positioned(
        bottom: -10.r,
        right: 60.r,
        child: _Circle(size: 24.r, opacity: 0.06),
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
    final (label, dotColor) = _labelAndDot(context);
    final isActive =
        status == EventStatus.open || status == EventStatus.voting;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 4.r),
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
              width: 6.r,
              height: 6.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
            SizedBox(width: 5.r),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _labelAndDot(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case EventStatus.open:
        return (l10n.open, const Color(0xFFBBF7D0));
      case EventStatus.voting:
        return (l10n.voting, const Color(0xFFFDE68A));
      case EventStatus.draft:
        return (l10n.upcoming, Colors.white);
      case EventStatus.closed:
        return (l10n.closed, Colors.white);
      case EventStatus.archived:
        return (l10n.archived, Colors.white);
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
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.description,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.sm),
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
        _buildPhaseChip(context),
        if (_hasTeamInfo()) ...[
          _dot(context),
          _buildTeamChip(context),
        ],
        if (event.status == EventStatus.voting &&
            event.maxCommunityVotes != null) ...[
          _dot(context),
          _iconLabel(
            context,
            Icons.how_to_vote_outlined,
            AppLocalizations.of(context)!.maxVotes(event.maxCommunityVotes!),
          ),
        ],
        const Spacer(),
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: AppSizes.iconSm,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseChip(BuildContext context) {
    final (icon, label, color) = _phaseInfo(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconXs, color: color),
        SizedBox(width: AppSpacing.xs),
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

  Widget _buildTeamChip(BuildContext context) {
    return _iconLabel(context, Icons.group_outlined, _teamLabel(context));
  }

  Widget _iconLabel(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconXs, color: context.colors.textHint),
        SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Small separator dot between metadata items.
  Widget _dot(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Container(
        width: 3.r,
        height: 3.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.textHint,
        ),
      ),
    );
  }

  bool _hasTeamInfo() =>
      event.minTeamSize != null || event.maxTeamSize != null;

  String _teamLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final min = event.minTeamSize;
    final max = event.maxTeamSize;
    if (min != null && max != null) return l10n.teamSizeRange(min, max);
    if (min != null) return l10n.teamSizeMin(min);
    if (max != null) return l10n.teamSizeMax(max);
    return '';
  }

  /// Returns (icon, label, color) for the current event phase.
  (IconData, String, Color) _phaseInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (event.status) {
      case EventStatus.open:
        return (
          Icons.edit_note_rounded,
          l10n.submissionsOpen,
          const Color(0xFF16A34A),
        );
      case EventStatus.voting:
        return (
          Icons.how_to_vote_rounded,
          l10n.voteNow,
          const Color(0xFF7C3AED),
        );
      case EventStatus.draft:
        return (
          Icons.schedule_rounded,
          l10n.comingSoon,
          context.colors.primary,
        );
      case EventStatus.closed:
        return (
          Icons.check_circle_outline_rounded,
          l10n.ended,
          context.colors.textHint,
        );
      case EventStatus.archived:
        return (
          Icons.inventory_2_outlined,
          l10n.archived,
          context.colors.textHint,
        );
    }
  }
}
