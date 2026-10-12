import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/api_endpoints.dart';
import 'package:frontend/data/models/detection_model.dart';
import 'package:frontend/core/network/http_client.dart';

class HistoryProvider extends ChangeNotifier {
  final _client = HttpClient();

  List<DetectionModel> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DetectionModel> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Fetch all user history
  Future<void> fetchHistory() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _client.get(ApiEndpoints.history);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _logs = data.map((json) => DetectionModel.fromJson(json)).toList();
        _setLoading(false);
      } else {
        _setError('Failed to fetch historical database logs.');
        _setLoading(false);
      }
    } catch (e) {
      _setError('Failed to connect to backend history services: $e');
      _setLoading(false);
    }
  }

  // Delete specific history record
  Future<bool> deleteHistoryItem(int id) async {
    try {
      final response = await _client.delete(ApiEndpoints.deleteHistoryItem(id));
      
      if (response.statusCode == 200) {
        _logs.removeWhere((item) => item.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
