import 'package:flutter/material.dart';
import 'package:shoe_store_app/models/user.dart';
import 'package:shoe_store_app/services/local_storage_service.dart';
import 'package:shoe_store_app/api/auth_api.dart';
import 'package:shoe_store_app/api/user_api.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  String? get errorMessage => _errorMessage;

  final LocalStorageService _localStorageService = LocalStorageService();
  final AuthApi _authApi = AuthApi();
  final UserApi _userApi = UserApi();

  // Method untuk clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Method untuk set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> initAuth() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _token = await _localStorageService.getJwtToken();
      if (_token != null) {
        _user = await _authApi.getLoggedInUser(_token!);
        if (_user == null) {
          // Token invalid or expired
          await _localStorageService.deleteJwtToken();
          _token = null;
          _setError('Session expired. Please login again.');
        }
      }
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
      print('Init auth error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authApi.login(email, password);
      
      if (result['success']) {
        _token = result['token'];
        _user = result['user'];
        await _localStorageService.saveJwtToken(_token!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Handle specific error cases
        String errorMessage = result['message'] ?? 'Login failed. Please try again.';
        
        // Check for specific error types
        if (errorMessage.toLowerCase().contains('password')) {
          _setError('Incorrect password. Please try again.');
        } else if (errorMessage.toLowerCase().contains('email') || 
                   errorMessage.toLowerCase().contains('user not found')) {
          _setError('Email not found. Please check your email or register.');
        } else if (errorMessage.toLowerCase().contains('invalid credentials')) {
          _setError('Invalid email or password. Please try again.');
        } else if (errorMessage.toLowerCase().contains('account')) {
          _setError('Account issue. Please contact support.');
        } else {
          _setError(errorMessage);
        }
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Handle different types of exceptions
      if (e.toString().contains('SocketException')) {
        _setError('No internet connection. Please check your network.');
      } else if (e.toString().contains('TimeoutException')) {
        _setError('Request timeout. Please try again.');
      } else if (e.toString().contains('401')) {
        _setError('Invalid email or password. Please try again.');
      } else if (e.toString().contains('404')) {
        _setError('Email not found. Please check your email or register.');
      } else if (e.toString().contains('500')) {
        _setError('Server error. Please try again later.');
      } else {
        _setError('Network error. Please check your connection and try again.');
      }
      
      print('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authApi.register(username, email, password, fullName);
      
      if (result['success']) {
        _token = result['token'];
        _user = result['user'];
        await _localStorageService.saveJwtToken(_token!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Handle specific registration errors
        String errorMessage = result['message'] ?? 'Registration failed. Please try again.';
        
        if (errorMessage.toLowerCase().contains('email already exists') ||
            errorMessage.toLowerCase().contains('email is already taken')) {
          _setError('Email already registered. Please use different email or login.');
        } else if (errorMessage.toLowerCase().contains('username already exists') ||
                   errorMessage.toLowerCase().contains('username is already taken')) {
          _setError('Username already taken. Please choose different username.');
        } else if (errorMessage.toLowerCase().contains('password')) {
          _setError('Password requirements not met. Please check password requirements.');
        } else if (errorMessage.toLowerCase().contains('email format') ||
                   errorMessage.toLowerCase().contains('invalid email')) {
          _setError('Invalid email format. Please enter valid email.');
        } else {
          _setError(errorMessage);
        }
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Handle different types of exceptions for registration
      if (e.toString().contains('SocketException')) {
        _setError('No internet connection. Please check your network.');
      } else if (e.toString().contains('TimeoutException')) {
        _setError('Request timeout. Please try again.');
      } else if (e.toString().contains('409')) {
        _setError('Email or username already exists. Please try different credentials.');
      } else if (e.toString().contains('400')) {
        _setError('Invalid registration data. Please check your information.');
      } else if (e.toString().contains('500')) {
        _setError('Server error. Please try again later.');
      } else {
        _setError('Network error. Please check your connection and try again.');
      }
      
      print('Registration error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _user = null;
      _token = null;
      _errorMessage = null;
      await _localStorageService.deleteJwtToken();
      notifyListeners();
    } catch (e) {
      _setError('Failed to logout properly: ${e.toString()}');
      print('Logout error: $e');
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _userApi.updateProfile(userData);
      _user = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile. Please try again.');
      print('Error updating user profile: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}