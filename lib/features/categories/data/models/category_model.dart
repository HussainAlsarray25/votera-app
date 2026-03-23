import 'package:votera/features/categories/domain/entities/category_entity.dart';

/// Data-layer representation of a category.
/// Extends [CategoryEntity] so it can be passed directly to the domain layer
/// without any extra mapping step.
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.description,
    super.createdAt,
    super.updatedAt,
  });

  /// Parses a category from the raw JSON returned by the API.
  /// The API uses snake_case keys, so we map them explicitly here
  /// rather than relying on code generation, keeping the model readable.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
