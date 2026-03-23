import 'package:equatable/equatable.dart';

/// Core business entity for a project category.
/// Kept intentionally lean -- only the fields the domain cares about.
class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;

  // Nullable because the API may omit timestamps on older records.
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, name, description, createdAt, updatedAt];
}
