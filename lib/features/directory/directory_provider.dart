import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';

class DirectoryUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'Cliente' or 'Profissional'
  final String status; // 'ativo', 'suspenso', etc.
  final String joinDate;
  final double rating;

  DirectoryUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinDate,
    required this.rating,
  });

  factory DirectoryUser.fromJson(Map<String, dynamic> json) {
    return DirectoryUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
      joinDate: json['joinDate'],
      rating: (json['rating'] as num).toDouble(),
    );
  }
}

class DirectoryProvider extends ChangeNotifier {
  List<DirectoryUser> _clients = [];
  List<DirectoryUser> _professionals = [];
  bool _isLoading = false;
  String? _error;

  List<DirectoryUser> get clients => _clients;
  List<DirectoryUser> get professionals => _professionals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDirectory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.get('/admin/diretorio');
      final cList = response['clientes'] as List;
      final pList = response['profissionais'] as List;

      _clients = cList.map((c) => DirectoryUser.fromJson(c)).toList();
      _professionals = pList.map((p) => DirectoryUser.fromJson(p)).toList();
    } catch (e) {
      _error = 'Erro ao carregar diretório: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleStatus(String role, String id) async {
    try {
      final type = role.toLowerCase() == 'cliente' ? 'client' : 'professional';
      await ApiClient.post('/admin/diretorio/suspend/$type/$id');
      await loadDirectory(); // Reload to get updated statuses
    } catch (e) {
      _error = 'Erro ao alterar status: $e';
      notifyListeners();
    }
  }
}
