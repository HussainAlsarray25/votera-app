import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:votera/core/constants/app_constants.dart';
import 'package:votera/features/authentication/domain/entities/telegram_auth.dart';

abstract class TokenService {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<void> clearTokens();
  Future<bool> hasToken();

  // Pending Telegram session — allows polling to resume after a process restart.
  Future<void> savePendingTelegramSession(String token, String link);
  Future<PendingTelegramSession?> loadPendingTelegramSession();
  Future<void> clearPendingTelegramSession();
}

class SecureTokenService implements TokenService {
  const SecureTokenService();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: AppConstants.accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Storage keys for the pending Telegram session.
  static const _tgPendingTokenKey = 'tg_pending_token';
  static const _tgPendingLinkKey = 'tg_pending_link';
  static const _tgPendingAtKey = 'tg_pending_at';

  @override
  Future<void> savePendingTelegramSession(String token, String link) async {
    await Future.wait([
      _storage.write(key: _tgPendingTokenKey, value: token),
      _storage.write(key: _tgPendingLinkKey, value: link),
      _storage.write(
        key: _tgPendingAtKey,
        value: DateTime.now().toIso8601String(),
      ),
    ]);
  }

  @override
  Future<PendingTelegramSession?> loadPendingTelegramSession() async {
    final results = await Future.wait([
      _storage.read(key: _tgPendingTokenKey),
      _storage.read(key: _tgPendingLinkKey),
      _storage.read(key: _tgPendingAtKey),
    ]);
    final token = results[0];
    final link = results[1];
    final savedAtRaw = results[2];
    if (token == null || link == null || savedAtRaw == null) return null;
    final savedAt = DateTime.tryParse(savedAtRaw);
    if (savedAt == null) return null;
    return PendingTelegramSession(token: token, link: link, savedAt: savedAt);
  }

  @override
  Future<void> clearPendingTelegramSession() async {
    await Future.wait([
      _storage.delete(key: _tgPendingTokenKey),
      _storage.delete(key: _tgPendingLinkKey),
      _storage.delete(key: _tgPendingAtKey),
    ]);
  }
}
