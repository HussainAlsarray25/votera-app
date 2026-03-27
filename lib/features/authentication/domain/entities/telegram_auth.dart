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

/// A pending Telegram session that was started but not yet completed.
/// Persisted locally so polling can resume if the app process is killed.
class PendingTelegramSession extends Equatable {
  const PendingTelegramSession({
    required this.token,
    required this.link,
    required this.savedAt,
  });

  final String token;
  final String link;

  // When the session was first saved (ISO-8601 timestamp).
  final DateTime savedAt;

  // Consider the session expired after 5 minutes — matching the polling window.
  bool get isExpired =>
      DateTime.now().difference(savedAt) >= const Duration(minutes: 5);

  @override
  List<Object?> get props => [token, link, savedAt];
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
