import 'package:flutter/material.dart';

/// Temporary demo data for exhibitions UI development.
/// Will be replaced by real data from the API via Cubit.

class DemoExhibition {
  const DemoExhibition({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.projectCount,
    required this.participantCount,
    required this.gradientColors,
  });

  final String id;
  final String name;
  final String description;
  final String emoji;
  final DateTime startDate;
  final DateTime endDate;
  final ExhibitionStatus status;
  final int projectCount;
  final int participantCount;
  final List<Color> gradientColors;
}

enum ExhibitionStatus { live, upcoming, ended }

/// Creates a fresh list of demo exhibitions for the home page.
List<DemoExhibition> createDemoExhibitions() {
  return [
    DemoExhibition(
      id: 'spring-hack-2026',
      name: 'Spring Hackathon 2026',
      description: 'Build innovative solutions in 48 hours. '
          'Open to all departments.',
      emoji: '\u{1F680}',
      startDate: DateTime(2026, 3, 10),
      endDate: DateTime(2026, 3, 25),
      status: ExhibitionStatus.live,
      projectCount: 42,
      participantCount: 186,
      gradientColors: const [Color(0xFF22C55E), Color(0xFF10B981)],
    ),
    DemoExhibition(
      id: 'ai-innovation-fair',
      name: 'AI Innovation Fair',
      description: 'Showcase AI and machine learning projects. '
          'Judges from top tech firms.',
      emoji: '\u{1F916}',
      startDate: DateTime(2026, 4, 5),
      endDate: DateTime(2026, 4, 12),
      status: ExhibitionStatus.upcoming,
      projectCount: 28,
      participantCount: 95,
      gradientColors: const [Color(0xFF3B82F6), Color(0xFF6366F1)],
    ),
    DemoExhibition(
      id: 'iot-challenge-2026',
      name: 'IoT Challenge 2026',
      description:
          'Connect the physical and digital world. Hardware kits provided.',
      emoji: '\u{1F33F}',
      startDate: DateTime(2026, 5),
      endDate: DateTime(2026, 5, 15),
      status: ExhibitionStatus.upcoming,
      projectCount: 15,
      participantCount: 64,
      gradientColors: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
    ),
    DemoExhibition(
      id: 'winter-tech-2025',
      name: 'Winter Tech Showcase 2025',
      description:
          "Last semester's best projects. Final results and awards announced.",
      emoji: '\u{2744}\u{FE0F}',
      startDate: DateTime(2025, 12),
      endDate: DateTime(2025, 12, 20),
      status: ExhibitionStatus.ended,
      projectCount: 56,
      participantCount: 230,
      gradientColors: const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    ),
  ];
}
