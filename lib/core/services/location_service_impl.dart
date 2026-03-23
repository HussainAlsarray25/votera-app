import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:votera/core/domain/services/location_service.dart';
import 'package:votera/core/error/failures.dart';

/// Geolocator-backed implementation of [LocationService].
/// Handles permission requests, service checks, and mock location detection.
class LocationServiceImpl implements LocationService {
  @override
  Future<Either<LocationFailure, GeoPosition>> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const Left(
        LocationFailure(message: 'Location services are disabled.'),
      );
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const Left(
          LocationFailure(message: 'Location permission was denied.'),
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const Left(
        LocationFailure(
          message: 'Location access is permanently denied. '
              'Please enable it in system settings.',
          isDeniedForever: true,
        ),
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition();

      // isMocked is only reliable on Android; on iOS/web it is always false.
      if (position.isMocked) {
        return const Left(
          LocationFailure(
            message: 'Mock locations detected. '
                'Voting requires your real location.',
          ),
        );
      }

      return Right(
        GeoPosition(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } on Exception {
      return const Left(
        LocationFailure(message: 'Failed to get current location.'),
      );
    }
  }
}
