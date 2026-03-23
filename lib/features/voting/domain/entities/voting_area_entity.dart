import 'package:equatable/equatable.dart';
import 'package:votera/core/domain/services/location_service.dart';

/// Represents the geographic boundary within which voting is allowed.
class VotingAreaEntity extends Equatable {
  const VotingAreaEntity({required this.eventId, required this.polygon});

  final String eventId;
  final List<GeoPosition> polygon;

  @override
  List<Object?> get props => [eventId, polygon];
}
