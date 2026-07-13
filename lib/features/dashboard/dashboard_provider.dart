import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';

class DashboardStats {
  final double faturacaoDiaria;
  final int chamadosAtivos;
  final int profissionaisOnline;
  final List<double> faturacao7Dias;

  DashboardStats({
    required this.faturacaoDiaria,
    required this.chamadosAtivos,
    required this.profissionaisOnline,
    required this.faturacao7Dias,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      faturacaoDiaria: (json['faturacao_diaria'] as num?)?.toDouble() ?? 0,
      chamadosAtivos: json['chamados_ativos'] as int? ?? 0,
      profissionaisOnline: json['profissionais_online'] as int? ?? 0,
      faturacao7Dias: (json['faturacao_7_dias'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ?? [],
    );
  }
}

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  DashboardStats? _stats;

  bool get isLoading => _isLoading;
  String? get error => _error;
  DashboardStats? get stats => _stats;

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.get('/admin/dashboard');
      _stats = DashboardStats.fromJson(response);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
