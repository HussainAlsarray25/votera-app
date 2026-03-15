abstract class AuthLocalDataSource {
  Future<void> cacheUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>?> getCachedUser();
  Future<void> clearCache();
}

class InMemoryAuthLocalDataSource implements AuthLocalDataSource {
  Map<String, dynamic>? _cachedUser;

  @override
  Future<void> cacheUser(Map<String, dynamic> user) async {
    _cachedUser = user;
  }

  @override
  Future<Map<String, dynamic>?> getCachedUser() async {
    return _cachedUser;
  }

  @override
  Future<void> clearCache() async {
    _cachedUser = null;
  }
}
