import 'package:votera/core/domain/services/location_service.dart';
import 'package:votera/features/voting/domain/entities/voting_area_entity.dart';

class VotingAreaModel extends VotingAreaEntity {
  const VotingAreaModel({required super.eventId, required super.polygon});

  factory VotingAreaModel.fromJson(Map<String, dynamic> json) {
    final rawPolygon = json['polygon'] as List<dynamic>? ?? [];
    final polygon = rawPolygon
        .cast<Map<String, dynamic>>()
        .map(
          (point) => GeoPosition(
            latitude: (point['latitude'] as num).toDouble(),
            longitude: (point['longitude'] as num).toDouble(),
          ),
        )
        .toList();

    return VotingAreaModel(
      eventId: json['event_id'] as String,
      polygon: polygon,
    );
  }
}
