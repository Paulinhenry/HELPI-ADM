import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String avatar;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar = 'https://ui-avatars.com/api/?name=Admin&background=0D8ABC&color=fff',
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      name: json['nome'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatar: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(json['nome'] as String)}&background=1A1D21&color=FFD700',
    );
  }
}

class AuthProvider extends ChangeNotifier {
  AdminUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AdminUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.post('/login/admin', body: {
        'email': email.trim().toLowerCase(),
        'senha': password,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', response['access_token']);
      
      _currentUser = AdminUser.fromJson(response['usuario']);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erro de conexão com o servidor.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
