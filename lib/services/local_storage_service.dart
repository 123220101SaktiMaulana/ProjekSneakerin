import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static const _secureStorage = FlutterSecureStorage();
  static const _jwtTokenKey = 'jwt_token';

  Future<void> saveJwtToken(String token) async {
    await _secureStorage.write(key: _jwtTokenKey, value: token);
  }

  Future<String?> getJwtToken() async {
    return await _secureStorage.read(key: _jwtTokenKey);
  }

  Future<void> deleteJwtToken() async {
    await _secureStorage.delete(key: _jwtTokenKey);
  }
}