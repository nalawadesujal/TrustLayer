import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/constants/api_endpoints.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:frontend/core/network/http_client.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _client = HttpClient();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String get username => _currentUser?.username ?? '';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Attempt login using email and password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _client.post(ApiEndpoints.login, {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        _currentUser = UserModel.fromJson(data['user']);

        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(
            key: 'user_data', value: jsonEncode(_currentUser!.toJson()));

        _setLoading(false);
        return true;
      } else {
        _setError(data['message'] ?? 'Authentication failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError("Failed to connect to authentication server: $e");
      _setLoading(false);
      return false;
    }
  }

  // Register a new user account
  Future<bool> register(String username, String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _client.post(ApiEndpoints.register, {
        'username': username,
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _setLoading(false);
        return true;
      } else {
        _setError(data['message'] ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError("Failed to connect to registration server: $e");
      _setLoading(false);
      return false;
    }
  }

  // Auto-login if JWT exists in storage
  Future<bool> tryAutoLogin() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return false;

    _setLoading(true);
    try {
      // Validate token by hitting history API
      final response = await _client.get(ApiEndpoints.history);

      if (response.statusCode == 200) {
        final storedUser = await _storage.read(key: 'user_data');
        if (storedUser != null) {
          _currentUser = UserModel.fromJson(jsonDecode(storedUser));
          notifyListeners();
        } else {
          await logout();
          _setLoading(false);
          return false;
        }
        _setLoading(false);
        return true;
      } else {
        await logout();
        _setLoading(false);
        return false;
      }
    } catch (e) {
      await logout();
      _setLoading(false);
      return false;
    }
  }

  // Logout and clear credentials
  Future<void> logout() async {
    _currentUser = null;
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_data');
    notifyListeners();
  }
}
