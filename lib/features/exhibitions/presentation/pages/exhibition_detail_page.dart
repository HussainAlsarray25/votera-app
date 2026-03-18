import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:votera/features/categories/presentation/widgets/categories_body.dart';
import 'package:votera/features/home/presentation/widgets/projects_tab_body.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/features/rankings/presentation/cubit/rankings_cubit.dart';
import 'package:votera/features/rankings/presentation/widgets/rankings_body.dart';
import 'package:votera/features/voting/presentation/cubit/voting_cubit.dart';

/// Detail page for a single exhibition, shown after tapping an exhibition card.
/// Contains a top TabBar with three tabs: Projects, Categories, Rankings.
class ExhibitionDetailPage extends StatefulWidget {
  const ExhibitionDetailPage({required this.exhibitionId, super.key});

  final String exhibitionId;

  @override
  State<ExhibitionDetailPage> createState() => _ExhibitionDetailPageState();
}

class _ExhibitionDetailPageState extends State<ExhibitionDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProjectsCubit>(create: (_) => sl<ProjectsCubit>()),
        BlocProvider<CategoriesCubit>(create: (_) => sl<CategoriesCubit>()),
        BlocProvider<RankingsCubit>(create: (_) => sl<RankingsCubit>()),
        BlocProvider<VotingCubit>(create: (_) => sl<VotingCubit>()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Exhibition',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textHint,
            indicatorColor: AppColors.primary,
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
            tabs: const [
              Tab(text: 'Projects'),
              Tab(text: 'Categories'),
              Tab(text: 'Rankings'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
