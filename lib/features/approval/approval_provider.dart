import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';

// ═══════════════════════════════════════════════════════════════
// Approval Provider — Gestão dos profissionais pendentes (KYP)
// ═══════════════════════════════════════════════════════════════

class PendingProfessional {
  final String id;
  final String name;
  final String category;
  final String status;
  final String date;
  final String cpf;
  final String city;
  final String phone;
  final String email;
  final String documentUrl;
  final String requestDate;
  final String documentName;

  PendingProfessional({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.date,
    required this.cpf,
    required this.city,
    required this.phone,
    required this.email,
    required this.documentUrl,
    required this.requestDate,
    required this.documentName,
  });

  factory PendingProfessional.fromJson(Map<String, dynamic> json) {
    return PendingProfessional(
      id: json['id'],
      name: json['name'],
      category: json['category'] ?? 'Geral',
      status: json['status'],
      date: json['date'],
      cpf: json['cpf'] ?? 'N/A',
      city: json['city'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      documentUrl: json['documentUrl'] ?? '',
      requestDate: json['date'],
      documentName: 'documento_oficial.pdf',
    );
  }
}

class ApprovalProvider extends ChangeNotifier {
  List<PendingProfessional> _pendingList = [];
  bool _isLoading = false;
  String? _error;

  List<PendingProfessional> get pendingList => _pendingList;
  int get pendingCount => _pendingList.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPending() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.get('/admin/kyp');
      _pendingList = (response as List).map((i) => PendingProfessional.fromJson(i)).toList();
    } catch (e) {
      _error = 'Erro ao carregar aprovações pendentes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approve(String id) async {
    try {
      await ApiClient.post('/admin/kyp-approve/$id');
      _pendingList.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao aprovar: $e';
      notifyListeners();
    }
  }

  Future<void> reject(String id) async {
    try {
      await ApiClient.post('/admin/kyp-reject/$id');
      _pendingList.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao rejeitar: $e';
      notifyListeners();
    }
  }
}
