import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';

// Purple-to-pink gradient palette cycled by list index.
const _cardGradients = [
  [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  [Color(0xFF7C3AED), Color(0xFF4F46E5)],
  [Color(0xFFA855F7), Color(0xFF8B5CF6)],
];

/// A tappable card summarising a team's name, member count, and description.
/// Used in search results and anywhere teams are listed.
class TeamCard extends StatelessWidget {
  const TeamCard({
    required this.team,
    required this.onTap,
    this.index = 0,
    super.key,
  });

  final TeamEntity team;
  final VoidCallback onTap;
  final int index;

  List<Color> get _colors => _cardGradients[index % _cardGradients.length];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: _colors.first.withValues(alpha: 0.18),
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
                _TeamCardHeader(colors: _colors, team: team),
                _TeamCardBody(team: team),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -- Header -------------------------------------------------------------------

class _TeamCardHeader extends StatelessWidget {
  const _TeamCardHeader({required this.colors, required this.team});

  final List<Color> colors;
  final TeamEntity team;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
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
          Positioned(
            top: -18,
            right: -12,
            child: _Circle(size: 72.r, opacity: 0.08),
          ),
          Positioned(
            top: 10,
            right: 28,
            child: _Circle(size: 40.r, opacity: 0.1),
          ),
          Positioned(
            bottom: -10,
            right: 60,
            child: _Circle(size: 24.r, opacity: 0.06),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team icon badge
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.group_rounded,
                  color: Colors.white,
                  size: AppSizes.iconMd,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                team.name,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -- Body ---------------------------------------------------------------------

class _TeamCardBody extends StatelessWidget {
  const _TeamCardBody({required this.team});

  final TeamEntity team;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (team.description != null && team.description!.isNotEmpty) ...[
            Text(
              team.description!,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
          ],
          Row(
            children: [
              Icon(
                Icons.group_outlined,
                size: AppSizes.iconXs,
                color: context.colors.textHint,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                '${team.members.length} '
                '${team.members.length == 1 ? 'member' : 'members'}',
                style: AppTypography.caption.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
          ),
        ],
      ),
    );
  }
}

// -- Decorative circle --------------------------------------------------------

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
