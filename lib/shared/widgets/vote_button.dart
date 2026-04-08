import 'dart:async';

import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// An animated vote button that scales on press and changes appearance when
/// the user has already voted for this project.
class VoteButton extends StatefulWidget {
  const VoteButton({
    required this.onVote,
    this.hasVoted = false,
    this.voteCount = 0,
    super.key,
  });

  final VoidCallback onVote;
  final bool hasVoted;
  final int voteCount;

  @override
  State<VoteButton> createState() => _VoteButtonState();
}

class _VoteButtonState extends State<VoteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 0.94), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    unawaited(_controller.forward(from: 0));
    widget.onVote();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.hasVoted ? _buildVotedState(context) : _buildVoteState(context),
    );
  }

  // Filled primary button shown when the user has not yet voted.
  Widget _buildVoteState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.how_to_vote_outlined,
              color: Colors.white,
              size: AppSizes.iconMd,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              l10n.vote,
              style: AppTypography.button.copyWith(color: Colors.white),
            ),
            if (widget.voteCount > 0) ...[
              SizedBox(width: AppSpacing.sm),
              _buildCountPill(
                count: widget.voteCount,
                background: Colors.white.withValues(alpha: 0.2),
                textColor: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Outlined / muted button shown after the user has already voted.
  Widget _buildVotedState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: context.colors.primary,
            size: AppSizes.iconMd,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            l10n.voted,
            style: AppTypography.button.copyWith(
              color: context.colors.primary,
            ),
          ),
          if (widget.voteCount > 0) ...[
            SizedBox(width: AppSpacing.sm),
            _buildCountPill(
              count: widget.voteCount,
              background: context.colors.primary.withValues(alpha: 0.12),
              textColor: context.colors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountPill({
    required int count,
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        '$count',
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
