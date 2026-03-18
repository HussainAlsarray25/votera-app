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
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return PaginatedResponse(
      items: rawItems
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? rawItems.length,
      total: json['total'] as int? ?? rawItems.length,
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
