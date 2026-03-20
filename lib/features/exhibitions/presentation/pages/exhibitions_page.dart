import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/app/view/shell_page.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/features/events/presentation/cubit/events_cubit.dart';
import 'package:votera/features/exhibitions/presentation/widgets/exhibition_card.dart';
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
        backgroundColor: AppColors.background,
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
                      const SliverToBoxAdapter(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, AppSpacing.md, 20, AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Votera',
                style: AppTypography.h1.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Explore exhibitions & events',
                style: AppTypography.bodyMedium,
              ),
            ],
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
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: AppLoadingIndicator(),
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
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: EmptyState(
                  icon: Icons.event_outlined,
                  title: 'No events yet',
                  subtitle:
                      'There are no exhibitions or events available right now. Check back later for updates.',
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = events[index];
                  return ExhibitionCard(
                    event: event,
                    index: index,
                    onTap: () => context.push('/exhibition/${event.id}'),
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
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.read<EventsCubit>().loadEvents(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
