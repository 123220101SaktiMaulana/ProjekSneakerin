import 'package:flutter/material.dart';
import 'package:shoe_store_app/models/user.dart';
import 'package:shoe_store_app/services/local_storage_service.dart';
import 'package:shoe_store_app/api/auth_api.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  final LocalStorageService _localStorageService = LocalStorageService();
  final AuthApi _authApi = AuthApi();

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    _token = await _localStorageService.getJwtToken();
    if (_token != null) {
      _user = await _authApi.getLoggedInUser(_token!);
      if (_user == null) { // Token invalid or expired
        await _localStorageService.deleteJwtToken();
        _token = null;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authApi.login(email, password);
    _isLoading = false;

    if (result['success']) {
      _token = result['token'];
      _user = result['user'];
      await _localStorageService.saveJwtToken(_token!);
      notifyListeners();
      return true;
    } else {
      // Handle error, maybe show a snackbar
      print('Login failed: ${result['message']}');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password, String fullName) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authApi.register(username, email, password, fullName);
    _isLoading = false;

    if (result['success']) {
      _token = result['token'];
      _user = result['user'];
      await _localStorageService.saveJwtToken(_token!);
      notifyListeners();
      return true;
    } else {
      print('Registration failed: ${result['message']}');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    await _localStorageService.deleteJwtToken();
    notifyListeners();
  }
}