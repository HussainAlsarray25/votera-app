import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/onboarding/presentation/widgets/onboarding_slide.dart';
import 'package:votera/features/onboarding/presentation/widgets/page_indicator.dart';
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

  static const _slides = [
    OnboardingData(
      title: 'Discover Projects',
      description:
          'Browse innovative software projects created by university students.',
    ),
    OnboardingData(
      title: 'Rate & Vote',
      description:
          'Vote for your favorite projects and help choose the winners.',
    ),
    OnboardingData(
      title: 'Celebrate Winners',
      description:
          'See trending projects and celebrate the top-voted creations.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToAuth() => context.go('/auth');

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        _buildSkipButton(),
        Expanded(child: _buildPageView()),
        _buildBottomSection(),
        const SizedBox(height: AppSpacing.xl),
      ],
    );

    // On wider screens, show the onboarding as a centered card
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
  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: TextButton(
          onPressed: _goToAuth,
          child: Text(
            'Skip',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textHint,
            ),
          ),
        ),
      ),
    );
  }

  // -- Section: Swipable slides --
  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _slides.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemBuilder: (context, index) {
        return OnboardingSlide(data: _slides[index]);
      },
    );
  }

  // -- Section: Indicator + action button --
  Widget _buildBottomSection() {
    final isLastPage = _currentPage == _slides.length - 1;

    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          PageIndicator(
            count: _slides.length,
            currentIndex: _currentPage,
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            text: isLastPage ? 'Get Started' : 'Next',
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
