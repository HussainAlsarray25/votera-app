import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';

/// Represents a geographic coordinate with latitude and longitude.
class GeoPosition {
  const GeoPosition({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// Platform-agnostic abstraction for obtaining the device's current location.
/// Implementations handle permission requests and platform differences.
abstract class LocationService {
  Future<Either<LocationFailure, GeoPosition>> getCurrentPosition();
}
