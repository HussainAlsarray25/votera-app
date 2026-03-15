import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/shared/widgets/project_card.dart';

/// A sliver list of project cards. Each card is interactive and
/// navigates to the project detail page on tap.
class ProjectListSection extends StatelessWidget {
  const ProjectListSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Static demo data -- will be replaced by Cubit state
    final projects = List.generate(6, _DemoProject.at);

    return SliverPadding(
      padding: AppSpacing.pagePadding,
      sliver: SliverList.separated(
        itemCount: projects.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final p = projects[index];
          return ProjectCard(
            title: p.title,
            authorName: p.author,
            imageUrl: p.imageUrl,
            rating: p.rating,
            voteCount: p.votes,
            isVerifiedAuthor: p.isVerified,
            isTrending: p.isTrending,
            isWinner: p.isWinner,
            onTap: () {
              // Navigate to project details
            },
          );
        },
      ),
    );
  }
}

/// Placeholder data for UI development. Remove once real data is connected.
class _DemoProject {
  const _DemoProject({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.rating,
    required this.votes,
    this.isVerified = false,
    this.isTrending = false,
    this.isWinner = false,
  });

  factory _DemoProject.at(int index) {
    const items = [
      _DemoProject(
        title: 'Smart Campus Navigator',
        author: 'Prof. Ahmed Ali',
        imageUrl: '',
        rating: 5,
        votes: 48,
        isVerified: true,
        isWinner: true,
      ),
      _DemoProject(
        title: 'AI Study Assistant',
        author: 'Sara Hassan',
        imageUrl: '',
        rating: 4,
        votes: 36,
        isTrending: true,
      ),
      _DemoProject(
        title: 'EcoTrack - Carbon Footprint',
        author: 'Omar Jamal',
        imageUrl: '',
        rating: 4,
        votes: 29,
        isTrending: true,
      ),
      _DemoProject(
        title: 'MedAssist Chatbot',
        author: 'Prof. Noor Kareem',
        imageUrl: '',
        rating: 3,
        votes: 22,
        isVerified: true,
      ),
      _DemoProject(
        title: 'Virtual Lab Simulator',
        author: 'Ali Mohammed',
        imageUrl: '',
        rating: 3,
        votes: 18,
      ),
      _DemoProject(
        title: 'CodeShare Platform',
        author: 'Fatima Zain',
        imageUrl: '',
        rating: 4,
        votes: 15,
      ),
    ];
    return items[index % items.length];
  }

  final String title;
  final String author;
  final String imageUrl;
  final int rating;
  final int votes;
  final bool isVerified;
  final bool isTrending;
  final bool isWinner;
}
