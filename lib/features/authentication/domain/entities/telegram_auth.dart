import 'package:equatable/equatable.dart';

/// Holds the data returned by the request-link endpoint.
/// [token] is the UUID used for polling; [link] is the tg:// deep link.
class TelegramLinkData extends Equatable {
  const TelegramLinkData({required this.token, required this.link});

  final String token;
  final String link;

  @override
  List<Object?> get props => [token, link];
}

/// Represents the outcome of a single poll against the status endpoint.
/// [isComplete] is true when the backend has issued JWTs and they have been
/// persisted locally. [isExpired] is true when the session token has expired
/// and the user must restart the flow.
class TelegramAuthStatus extends Equatable {
  const TelegramAuthStatus({
    required this.isComplete,
    this.isExpired = false,
  });

  final bool isComplete;
  final bool isExpired;

  @override
  List<Object?> get props => [isComplete, isExpired];
}
