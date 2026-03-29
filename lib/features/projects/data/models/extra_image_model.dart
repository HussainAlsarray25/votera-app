import 'package:votera/features/projects/domain/entities/extra_image_entity.dart';

/// Data model for [ExtraImageEntity]. Handles JSON deserialization
/// from the `images` array in the project response.
class ExtraImageModel extends ExtraImageEntity {
  const ExtraImageModel({
    required super.id,
    required super.url,
  });

  factory ExtraImageModel.fromJson(Map<String, dynamic> json) {
    return ExtraImageModel(
      id: json['id']?.toString() ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}
