import 'dart:math' as math;

import 'package:votera/core/domain/services/location_service.dart';

/// Earth's mean radius in metres, used for Haversine calculations.
const double _earthRadiusMetres = 6371000;

/// Returns true if [point] is within [radiusMetres] of [centre].
///
/// Uses the Haversine formula to compute the great-circle distance between
/// the two coordinates. If [centre] is null the check is skipped and the
/// function returns true (no restriction configured).
bool isWithinRadius(
  GeoPosition point,
  GeoPosition? centre, {
  double radiusMetres = 500,
}) {
  if (centre == null) return true;

  final dLat = _toRadians(point.latitude - centre.latitude);
  final dLng = _toRadians(point.longitude - centre.longitude);

  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(centre.latitude)) *
          math.cos(_toRadians(point.latitude)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);

  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  final distance = _earthRadiusMetres * c;

  return distance <= radiusMetres;
}

double _toRadians(double degrees) => degrees * math.pi / 180;

/// Tolerance for floating-point comparisons in boundary checks.
const double _epsilon = 1e-9;

/// Determines whether [point] lies inside the polygon defined by [vertices].
///
/// Returns `true` when:
/// - The polygon has fewer than 3 vertices (no restriction configured).
/// - The point lies on a vertex or edge of the polygon.
/// - The point is strictly inside the polygon (ray-casting algorithm).
bool isPointInPolygon(GeoPosition point, List<GeoPosition> vertices) {
  if (vertices.length < 3) return true;

  // Check if the point coincides with any vertex or lies on any edge.
  for (var i = 0; i < vertices.length; i++) {
    final a = vertices[i];
    final b = vertices[(i + 1) % vertices.length];

    if (_isPointOnSegment(point, a, b)) return true;
  }

  // Ray-casting: count edge crossings for a ray cast rightward from point.
  var inside = false;
  for (var i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
    final vi = vertices[i];
    final vj = vertices[j];

    final intersects = ((vi.longitude > point.longitude) !=
            (vj.longitude > point.longitude)) &&
        (point.latitude <
            (vj.latitude - vi.latitude) *
                    (point.longitude - vi.longitude) /
                    (vj.longitude - vi.longitude) +
                vi.latitude);

    if (intersects) inside = !inside;
  }

  return inside;
}

/// Returns true if [p] lies on the line segment from [a] to [b],
/// using epsilon tolerance for floating-point precision.
bool _isPointOnSegment(GeoPosition p, GeoPosition a, GeoPosition b) {
  // Cross product to check collinearity.
  final cross = (p.latitude - a.latitude) * (b.longitude - a.longitude) -
      (p.longitude - a.longitude) * (b.latitude - a.latitude);

  if (cross.abs() > _epsilon) return false;

  // Check that p is within the bounding box of the segment.
  final minLat = a.latitude < b.latitude ? a.latitude : b.latitude;
  final maxLat = a.latitude > b.latitude ? a.latitude : b.latitude;
  final minLng = a.longitude < b.longitude ? a.longitude : b.longitude;
  final maxLng = a.longitude > b.longitude ? a.longitude : b.longitude;

  return p.latitude >= minLat - _epsilon &&
      p.latitude <= maxLat + _epsilon &&
      p.longitude >= minLng - _epsilon &&
      p.longitude <= maxLng + _epsilon;
}
