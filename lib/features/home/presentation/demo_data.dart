import 'package:flutter/material.dart';

/// Temporary demo data for UI development.
/// Will be replaced by real data from the API via Cubit.

class DemoProject {
  DemoProject({
    required this.title,
    required this.description,
    required this.category,
    required this.teamName,
    required this.teamInitial,
    required this.teamColors,
    required this.members,
    required this.emoji,
    required this.votes,
    this.isVoted = false,
  });

  final String title;
  final String description;
  final String category;
  final String teamName;
  final String teamInitial;
  final List<Color> teamColors;
  final List<DemoTeamMember> members;
  final String emoji;
  int votes;
  bool isVoted;
}

class DemoTeamMember {
  const DemoTeamMember({required this.initial, required this.colors});

  final String initial;
  final List<Color> colors;
}

// Available category filters
const List<String> projectCategories = [
  'All Projects',
  'Web Dev',
  'Mobile Apps',
  'Game',
  'AI / ML',
  'Data',
  'IoT',
];

/// Creates a fresh list of demo projects for the home page.
List<DemoProject> createDemoProjects() {
  return [
    DemoProject(
      title: 'NeuroSync Assistant',
      description:
          'An AI-powered daily assistant that organizes your study schedule...',
      category: 'AI / ML',
      teamName: 'Team Alpha',
      teamInitial: 'A',
      teamColors: const [Color(0xFF3B82F6), Color(0xFF6366F1)],
      members: const [
        DemoTeamMember(
          initial: 'A',
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
        ),
        DemoTeamMember(
          initial: 'R',
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        DemoTeamMember(
          initial: 'L',
          colors: [Color(0xFF22C55E), Color(0xFF10B981)],
        ),
      ],
      emoji: '\u{1F916}',
      votes: 428,
    ),
    DemoProject(
      title: 'EcoSmart Dashboard',
      description:
          'IoT sensor network that monitors energy consumption on campus...',
      category: 'IoT',
      teamName: 'GreenBit',
      teamInitial: 'G',
      teamColors: const [Color(0xFF22C55E), Color(0xFF10B981)],
      members: const [
        DemoTeamMember(
          initial: 'G',
          colors: [Color(0xFF22C55E), Color(0xFF10B981)],
        ),
        DemoTeamMember(
          initial: 'T',
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        ),
      ],
      emoji: '\u{1F33F}',
      votes: 312,
    ),
    DemoProject(
      title: 'StudyHub Platform',
      description:
          'A collaborative platform for peer-to-peer learning sessions...',
      category: 'Web Dev',
      teamName: 'StackFlow',
      teamInitial: 'S',
      teamColors: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
      members: const [
        DemoTeamMember(
          initial: 'S',
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        ),
        DemoTeamMember(
          initial: 'T',
          colors: [Color(0xFF22C55E), Color(0xFF10B981)],
        ),
      ],
      emoji: '\u{1F310}',
      votes: 256,
    ),
    DemoProject(
      title: 'Campus Quest AR',
      description:
          'An augmented reality scavenger hunt to help freshmen explore campus',
      category: 'Game',
      teamName: 'PixelCrew',
      teamInitial: 'P',
      teamColors: const [Color(0xFFEC4899), Color(0xFF8B5CF6)],
      members: const [
        DemoTeamMember(
          initial: 'P',
          colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
        ),
        DemoTeamMember(
          initial: 'K',
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
        ),
        DemoTeamMember(
          initial: 'M',
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        ),
      ],
      emoji: '\u{1F3AE}',
      votes: 189,
    ),
    DemoProject(
      title: 'RideShare Campus',
      description:
          'Carpooling app connecting students with similar commute routes',
      category: 'Mobile Apps',
      teamName: 'DriveDev',
      teamInitial: 'D',
      teamColors: const [Color(0xFFEF4444), Color(0xFFF97316)],
      members: const [
        DemoTeamMember(
          initial: 'D',
          colors: [Color(0xFFEF4444), Color(0xFFF97316)],
        ),
        DemoTeamMember(
          initial: 'N',
          colors: [Color(0xFF3B82F6), Color(0xFF22C55E)],
        ),
      ],
      emoji: '\u{1F4F1}',
      votes: 198,
    ),
    DemoProject(
      title: 'MealMind AI',
      description:
          'Smart meal planner that learns dietary preferences and budget',
      category: 'AI / ML',
      teamName: 'BrainBite',
      teamInitial: 'B',
      teamColors: const [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
      members: const [
        DemoTeamMember(
          initial: 'B',
          colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
        ),
        DemoTeamMember(
          initial: 'J',
          colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
        ),
      ],
      emoji: '\u{1F37D}\u{FE0F}',
      votes: 341,
    ),
    DemoProject(
      title: 'GradeFlow Analytics',
      description:
          'Visualize academic performance trends with predictive insights',
      category: 'Data',
      teamName: 'DataViz',
      teamInitial: 'V',
      teamColors: const [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
      members: const [
        DemoTeamMember(
          initial: 'V',
          colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
        ),
        DemoTeamMember(
          initial: 'Z',
          colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
        ),
        DemoTeamMember(
          initial: 'Q',
          colors: [Color(0xFF22C55E), Color(0xFF3B82F6)],
        ),
      ],
      emoji: '\u{1F4CA}',
      votes: 274,
    ),
  ];
}

/// Maps each category to its visual styling colors.
/// Centralizes the color logic so trending cards and list items stay in sync.
class CategoryStyles {
  CategoryStyles._();

  /// Gradient background for trending card headers
  static List<Color> cardGradient(String category) {
    switch (category) {
      case 'AI / ML':
        return const [Color(0xFF0F172A), Color(0xFF1E3A5F)];
      case 'IoT':
        return const [Color(0xFFFEF9C3), Color(0xFFFED7AA)];
      case 'Web Dev':
        return const [Color(0xFFDBEAFE), Color(0xFFC7D2FE)];
      case 'Game':
        return const [Color(0xFFFCE7F3), Color(0xFFF5D0FE)];
      case 'Mobile Apps':
        return const [Color(0xFFFEF3C7), Color(0xFFFDE68A)];
      case 'Data':
        return const [Color(0xFFF3E8FF), Color(0xFFE9D5FF)];
      default:
        return const [Color(0xFFE5E7EB), Color(0xFFD1D5DB)];
    }
  }

  /// Solid color for category badge on trending cards
  static Color tagColor(String category) {
    switch (category) {
      case 'AI / ML':
        return const Color(0xFF3B82F6);
      case 'IoT':
        return const Color(0xFF8B5CF6);
      case 'Web Dev':
        return const Color(0xFF22C55E);
      case 'Game':
        return const Color(0xFFEC4899);
      case 'Mobile Apps':
        return const Color(0xFFD97706);
      case 'Data':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// Background and text color pair for category tags in list items
  static ({Color background, Color text}) tagStyles(String category) {
    switch (category) {
      case 'AI / ML':
        return (
          background: const Color(0xFFDCFCE7),
          text: const Color(0xFF16A34A),
        );
      case 'IoT':
        return (
          background: const Color(0xFFEDE9FE),
          text: const Color(0xFF7C3AED),
        );
      case 'Web Dev':
        return (
          background: const Color(0xFFDBEAFE),
          text: const Color(0xFF2563EB),
        );
      case 'Game':
        return (
          background: const Color(0xFFFCE7F3),
          text: const Color(0xFFDB2777),
        );
      case 'Mobile Apps':
        return (
          background: const Color(0xFFFEF3C7),
          text: const Color(0xFFD97706),
        );
      case 'Data':
        return (
          background: const Color(0xFFF3E8FF),
          text: const Color(0xFF7C3AED),
        );
      default:
        return (
          background: const Color(0xFFF3F4F6),
          text: const Color(0xFF6B7280),
        );
    }
  }

  /// Vibrant gradient for podium avatars on the rankings page
  static List<Color> podiumGradient(String category) {
    switch (category) {
      case 'AI / ML':
        return const [Color(0xFF0F172A), Color(0xFF1E3A5F)];
      case 'IoT':
        return const [Color(0xFF86EFAC), Color(0xFF22C55E)];
      case 'Web Dev':
        return const [Color(0xFF93C5FD), Color(0xFF3B82F6)];
      case 'Game':
        return const [Color(0xFFF9A8D4), Color(0xFFEC4899)];
      case 'Mobile Apps':
        return const [Color(0xFFFDE68A), Color(0xFFF59E0B)];
      case 'Data':
        return const [Color(0xFFC4B5FD), Color(0xFF8B5CF6)];
      default:
        return const [Color(0xFFE5E7EB), Color(0xFF9CA3AF)];
    }
  }

  /// Soft gradient background for project icon in list items
  static List<Color> iconBackground(String category) {
    switch (category) {
      case 'AI / ML':
        return const [Color(0xFFF0FDF4), Color(0xFFDCFCE7)];
      case 'IoT':
        return const [Color(0xFFEDE9FE), Color(0xFFDDD6FE)];
      case 'Web Dev':
        return const [Color(0xFFDBEAFE), Color(0xFFBFDBFE)];
      case 'Game':
        return const [Color(0xFFEDE9FE), Color(0xFFDDD6FE)];
      case 'Mobile Apps':
        return const [Color(0xFFFEF3C7), Color(0xFFFDE68A)];
      case 'Data':
        return const [Color(0xFFFCE7F3), Color(0xFFFBCFE8)];
      default:
        return const [Color(0xFFF3F4F6), Color(0xFFE5E7EB)];
    }
  }
}
