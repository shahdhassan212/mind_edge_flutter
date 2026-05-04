// core/storage/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _s = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) =>
      Future.wait([
        _s.write(key: kStorageAccessToken, value: accessToken),
        _s.write(key: kStorageRefreshToken, value: refreshToken),
      ]);

  Future<void> saveAccessToken(String t) => _s.write(key: kStorageAccessToken, value: t);
  Future<void> saveRefreshToken(String t) => _s.write(key: kStorageRefreshToken, value: t);
  Future<void> saveUserData(String json) => _s.write(key: kStorageUserData, value: json);

  Future<String?> getAccessToken() => _s.read(key: kStorageAccessToken);
  Future<String?> getRefreshToken() => _s.read(key: kStorageRefreshToken);
  Future<String?> getUserData() => _s.read(key: kStorageUserData);

  Future<bool> hasValidToken() async {
    final t = await getAccessToken();
    return t != null && t.isNotEmpty;
  }

  Future<void> clearTokens() => Future.wait([
        _s.delete(key: kStorageAccessToken),
        _s.delete(key: kStorageRefreshToken),
      ]);

  Future<void> clearAll() => _s.deleteAll();
}
