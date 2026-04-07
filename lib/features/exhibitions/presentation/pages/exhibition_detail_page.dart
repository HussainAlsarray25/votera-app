import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:votera/features/categories/presentation/widgets/categories_body.dart';
import 'package:votera/features/exhibitions/presentation/widgets/my_project_body.dart';
import 'package:votera/features/home/presentation/widgets/projects_tab_body.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/features/rankings/presentation/cubit/rankings_cubit.dart';
import 'package:votera/features/rankings/presentation/widgets/rankings_body.dart';
import 'package:votera/features/events/domain/entities/event_entity.dart';
import 'package:votera/features/voting/presentation/cubit/voting_cubit.dart';

/// Detail page for a single exhibition, shown after tapping an exhibition card.
///
/// Contains a top TabBar with tabs for Projects, Categories, and Rankings.
/// Participants (non-visitor roles) also see a "My Project" tab at the end
/// that shows their own project submission for this event.
class ExhibitionDetailPage extends StatefulWidget {
  const ExhibitionDetailPage({
    required this.exhibitionId,
    required this.eventStatus,
    super.key,
  });

  final String exhibitionId;

  /// The lifecycle status of the event, used to gate the My Project tab.
  final EventStatus eventStatus;

  @override
  State<ExhibitionDetailPage> createState() => _ExhibitionDetailPageState();
}

class _ExhibitionDetailPageState extends State<ExhibitionDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Whether the logged-in user can see the My Project tab.
  // Determined once on build when the profile is available.
  bool _canViewMyProject = false;

  @override
  void initState() {
    super.initState();
    // Resolve tab count based on current profile role.
    // ProfileCubit is provided globally at the App level.
    final profileState = context.read<ProfileCubit>().state;
    // Show tab for any verified role (participant, admin, organizer, etc.).
    _canViewMyProject = profileState is ProfileLoaded
        ? !profileState.profile.isVisitorOnly
        : false;

    _tabController = TabController(
      length: _canViewMyProject ? 4 : 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProjectsCubit>(create: (_) => sl<ProjectsCubit>()),
        BlocProvider<CategoriesCubit>(create: (_) => sl<CategoriesCubit>()),
        BlocProvider<RankingsCubit>(create: (_) => sl<RankingsCubit>()),
        BlocProvider<VotingCubit>(create: (_) => sl<VotingCubit>()),
      ],
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            l10n.exhibition,
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: context.colors.textPrimary,
            unselectedLabelColor: context.colors.textHint,
            indicatorColor: context.colors.primary,
            dividerHeight: 0,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: l10n.projects),
              Tab(text: l10n.categories),
              Tab(text: l10n.rankings),
              if (_canViewMyProject) Tab(text: l10n.myProject),
            ],
          ),
        ),
        body: SafeArea(
          child: CenteredContent(
            child: TabBarView(
              controller: _tabController,
              children: [
                ProjectsTabBody(eventId: widget.exhibitionId),
                CategoriesBody(eventId: widget.exhibitionId),
                RankingsBody(eventId: widget.exhibitionId),
                if (_canViewMyProject)
                  MyProjectBody(
                    eventId: widget.exhibitionId,
                    eventStatus: widget.eventStatus,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
