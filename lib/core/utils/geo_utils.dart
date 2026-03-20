import 'package:votera/core/domain/services/location_service.dart';

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
