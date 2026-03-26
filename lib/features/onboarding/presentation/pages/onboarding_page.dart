import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/onboarding/presentation/widgets/onboarding_slide.dart';
import 'package:votera/features/onboarding/presentation/widgets/page_indicator.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// Three-slide onboarding that introduces the app to first-time users.
/// Auto-advances optional; manual swipe and skip are always available.
/// On tablet/desktop, renders as a centered card.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToAuth() => context.go('/auth');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Built inside build() because it depends on localized strings from context.
    final slides = [
      OnboardingData(
        title: l10n.discoverOnboarding,
        description: l10n.discoverOnboardingDesc,
      ),
      OnboardingData(
        title: l10n.rateVote,
        description: l10n.rateVoteDesc,
      ),
      OnboardingData(
        title: l10n.celebrateWinners,
        description: l10n.celebrateWinnersDesc,
      ),
    ];

    final content = Column(
      children: [
        _buildSkipButton(l10n),
        Expanded(child: _buildPageView(slides)),
        _buildBottomSection(l10n, slides),
        const SizedBox(height: AppSpacing.xl),
      ],
    );

    // On wider screens, show the onboarding as a centered card.
    if (!AppBreakpoints.isMobile(context)) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 560,
                maxHeight: 700,
              ),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                clipBehavior: Clip.antiAlias,
                child: content,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(child: content),
    );
  }

  // -- Section: Skip button (subtle, secondary style) --
  Widget _buildSkipButton(AppLocalizations l10n) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: TextButton(
          onPressed: _goToAuth,
          child: Text(
            l10n.skip,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textHint,
            ),
          ),
        ),
      ),
    );
  }

  // -- Section: Swipable slides --
  Widget _buildPageView(List<OnboardingData> slides) {
    return PageView.builder(
      controller: _pageController,
      itemCount: slides.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemBuilder: (context, index) {
        return OnboardingSlide(data: slides[index]);
      },
    );
  }

  // -- Section: Indicator + action button --
  Widget _buildBottomSection(AppLocalizations l10n, List<OnboardingData> slides) {
    final isLastPage = _currentPage == slides.length - 1;

    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          PageIndicator(
            count: slides.length,
            currentIndex: _currentPage,
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            text: isLastPage ? l10n.getStarted : l10n.next,
            onPressed: () {
              if (isLastPage) {
                _goToAuth();
              } else {
                unawaited(
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Simple data holder for each onboarding slide.
class OnboardingData {
  const OnboardingData({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
