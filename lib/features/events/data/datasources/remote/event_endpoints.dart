/// Centralized endpoint paths for the events feature.
/// All paths are relative (no leading slash, no version prefix).
class EventEndpoints {
  const EventEndpoints._();

  static const String events = 'events';

  static String eventById(String id) => 'events/$id';
}
