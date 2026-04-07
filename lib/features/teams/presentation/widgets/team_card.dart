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

// Royal gradient used exclusively for the "Frogs Team" special case.
const _royalGradient = [Color(0xFF1A0045), Color(0xFF5B0092)];

// The team name that receives the royal treatment.
const _royalTeamName = 'Frogs Team';

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

  bool get _isRoyal => team.name == _royalTeamName;
  List<Color> get _colors =>
      _isRoyal ? _royalGradient : _cardGradients[index % _cardGradients.length];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: _colors.first.withValues(alpha: _isRoyal ? 0.35 : 0.18),
              blurRadius: _isRoyal ? 32 : 24,
              offset: const Offset(0, 8),
            ),
            // Extra golden glow for the royal card.
            if (_isRoyal)
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          // Golden border only on the royal card.
          border: _isRoyal
              ? Border.all(color: const Color(0xFFFFD700), width: 1.5)
              : null,
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
                _TeamCardHeader(
                  colors: _colors,
                  team: team,
                  isRoyal: _isRoyal,
                ),
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
  const _TeamCardHeader({
    required this.colors,
    required this.team,
    this.isRoyal = false,
  });

  final List<Color> colors;
  final TeamEntity team;
  final bool isRoyal;

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
          // Golden shimmer orb in the top-right for the royal card.
          if (isRoyal)
            Positioned(
              top: -8,
              right: 8,
              child: Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withValues(alpha: 0.25),
                      const Color(0xFFFFD700).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRoyal)
                // Crown replaces the group icon for the royal team.
                _RoyalCrownBadge()
              else
                // Standard team icon badge.
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
                  // Golden text for the royal team, white for others.
                  color: isRoyal ? const Color(0xFFFFD700) : Colors.white,
                  height: 1.25,
                  shadows: isRoyal
                      ? [
                          Shadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
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

// -- Royal crown badge --------------------------------------------------------

/// The crown badge shown in the header of the royal "Frogs Team" card.
/// Mirrors the gold styling used on the rankings podium.
class _RoyalCrownBadge extends StatelessWidget {
  const _RoyalCrownBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          // Same crown used on the rankings podium for 1st place.
          '\u{1F451}',
          style: TextStyle(fontSize: 22.sp),
        ),
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
