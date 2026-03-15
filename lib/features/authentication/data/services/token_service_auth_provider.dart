import 'package:votera/core/domain/services/auth_token_provider.dart';
import 'package:votera/features/authentication/data/services/token_service.dart';

class TokenServiceAuthProvider implements AuthTokenProvider {
  const TokenServiceAuthProvider({required this.tokenService});

  final TokenService tokenService;

  @override
  Future<String?> getAccessToken() => tokenService.getAccessToken();

  @override
  Future<String?> getRefreshToken() => tokenService.getRefreshToken();

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await tokenService.saveAccessToken(accessToken);
    await tokenService.saveRefreshToken(refreshToken);
  }

  @override
  Future<void> clearTokens() => tokenService.clearTokens();

  @override
  Future<bool> isAuthenticated() => tokenService.hasToken();
}
