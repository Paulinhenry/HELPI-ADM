import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';

class RadarService {
  final String id;
  final String clientName;
  final String professionalName;
  final String category;
  final double value;
  final String status; // 'pendente', 'em_andamento', 'concluido'
  final String date;

  RadarService({
    required this.id,
    required this.clientName,
    required this.professionalName,
    required this.category,
    required this.value,
    required this.status,
    required this.date,
  });

  factory RadarService.fromJson(Map<String, dynamic> json) {
    return RadarService(
      id: json['id'],
      clientName: json['clientName'],
      professionalName: json['professionalName'],
      category: json['category'],
      value: (json['value'] as num).toDouble(),
      status: json['status'],
      date: json['date'],
    );
  }
}

class RadarProfessional {
  final String name;
  final String category;
  final String location;
  final double rating;

  RadarProfessional({
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
  });

  factory RadarProfessional.fromJson(Map<String, dynamic> json) {
    return RadarProfessional(
      name: json['name'],
      category: json['category'],
      location: json['location'],
      rating: (json['rating'] as num).toDouble(),
    );
  }
}

class ServicesProvider extends ChangeNotifier {
  List<RadarService> _services = [];
  List<RadarProfessional> _onlineProfessionals = [];
  bool _isLoading = false;
  String? _error;

  List<RadarService> get services => _services;
  List<RadarProfessional> get onlineProfessionals => _onlineProfessionals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get onlineCount => _onlineProfessionals.length;
  int get totalServices => _services.length;
  int get activeServices => _services.where((s) => s.status == 'em_andamento').length;

  Future<void> loadRadar() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.get('/admin/radar');
      
      final servList = response['services'] as List;
      final profList = response['onlineProfessionals'] as List;

      _services = servList.map((s) => RadarService.fromJson(s)).toList();
      _onlineProfessionals = profList.map((p) => RadarProfessional.fromJson(p)).toList();
    } catch (e) {
      _error = 'Erro ao carregar dados do radar: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
