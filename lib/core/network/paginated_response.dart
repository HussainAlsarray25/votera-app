import 'package:equatable/equatable.dart';

/// Generic paginated response for list endpoints.
/// Non-identity modules return: {items[], page, size, total}
class PaginatedResponse<T> extends Equatable {
  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
  });

  /// Parse from JSON using the provided item factory.
  /// Automatically unwraps the API envelope when the paginated payload
  /// is nested under a top-level `data` key
  /// (e.g. `{success, message, data: {items, page, size, total}}`).
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final hasEnvelope = json.containsKey('data') &&
        json['data'] is Map<String, dynamic>;
    final payload =
        hasEnvelope ? json['data'] as Map<String, dynamic> : json;

    final rawItems = payload['items'] as List<dynamic>? ?? [];
    return PaginatedResponse(
      items: rawItems
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      page: payload['page'] as int? ?? 1,
      size: payload['size'] as int? ?? rawItems.length,
      total: payload['total'] as int? ?? rawItems.length,
    );
  }

  final List<T> items;
  final int page;
  final int size;
  final int total;

  bool get hasNextPage => page * size < total;

  @override
  List<Object?> get props => [items, page, size, total];
}
