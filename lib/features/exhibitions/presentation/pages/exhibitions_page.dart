import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/app/view/shell_page.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/features/events/presentation/cubit/events_cubit.dart';
import 'package:votera/features/exhibitions/presentation/widgets/exhibition_card.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
import 'package:votera/shared/widgets/empty_state.dart';

/// Main home page showing a list of exhibitions/events.
/// Loads real event data from the API via EventsCubit.
class ExhibitionsPage extends StatelessWidget {
  const ExhibitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventsCubit>(
      create: (_) => sl<EventsCubit>()..loadEvents(),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: CenteredContent(
            child: BlocBuilder<EventsCubit, EventsState>(
              buildWhen: (_, current) => current is EventsLoaded,
              builder: (context, _) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<EventsCubit>().loadEvents();
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(context)),
                      const _EventsListSliver(),
                      SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xxl),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, AppSpacing.md, 20.r, AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.exhibitions,
                style: AppTypography.h1.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: context.colors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.r),
              Text(
                l10n.exploreExhibitions,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          ),
          const NotificationIconButton(),
        ],
      ),
    );
  }
}

/// Separate widget to access the EventsCubit provided above.
class _EventsListSliver extends StatelessWidget {
  const _EventsListSliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading || state is EventsInitial) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80.r),
                child: const AppLoadingIndicator(),
              ),
            ),
          );
        }

        if (state is EventsError) {
          return SliverToBoxAdapter(
            child: _buildErrorState(context, state.message),
          );
        }

        if (state is EventsLoaded) {
          final events = state.response.items;
          if (events.isEmpty) {
            final l10n = AppLocalizations.of(context)!;
            return SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 80.r),
                child: EmptyState(
                  icon: Icons.event_outlined,
                  title: l10n.noEventsYet,
                  subtitle: l10n.noEventsDesc,
                ),
              ),
            );
          }

          final columns = AppBreakpoints.projectGridColumns(context);

          // Mobile: a simple vertical list with natural card heights.
          // Tablet/Desktop: a multi-column grid that fills the wider viewport.
          // mainAxisExtent is sized to comfortably fit the gradient header
          // (status badge, title up to 2 lines, date) plus the card body
          // (description up to 2 lines and metadata row).
          if (columns == 1) {
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.r),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = events[index];
                    return ExhibitionCard(
                      event: event,
                      index: index,
                      onTap: () => context.push(
                        '/exhibition/${event.id}',
                        extra: event.status,
                      ),
                    );
                  },
                  childCount: events.length,
                ),
              ),
            );
          }

          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                mainAxisExtent: 270,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = events[index];
                  return ExhibitionCard(
                    event: event,
                    index: index,
                    onTap: () => context.push(
                        '/exhibition/${event.id}',
                        extra: event.status,
                      ),
                  );
                },
                childCount: events.length,
              ),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: EdgeInsets.only(top: 80.r),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: AppSizes.iconXxl, color: context.colors.error),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.read<EventsCubit>().loadEvents(),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}
