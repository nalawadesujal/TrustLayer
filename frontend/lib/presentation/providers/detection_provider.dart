import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/api_endpoints.dart';
import 'package:frontend/data/models/detection_model.dart';
import 'package:frontend/core/network/http_client.dart';

class DetectionProvider extends ChangeNotifier {
  final _client = HttpClient();

  bool _isLoading = false;
  String? _errorMessage;
  DetectionModel? _lastResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DetectionModel? get lastResult => _lastResult;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void reset() {
    _lastResult = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // Text AI Detection request
  Future<DetectionModel?> analyzeText(String text) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _client.post(ApiEndpoints.detectText, {'text': text});
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _lastResult = DetectionModel.fromJson(data);
        _setLoading(false);
        return _lastResult;
      } else {
        _setError(data['message'] ?? 'Failed to analyze text.');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Failed to contact text detection backend: $e');
      _setLoading(false);
      return null;
    }
  }

  // Image AI Detection request (multipart file)
  Future<DetectionModel?> analyzeImage(String filePath) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _client.postMultipart(
        ApiEndpoints.detectImage, 
        filePath, 
        'image',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _lastResult = DetectionModel.fromJson(data);
        _setLoading(false);
        return _lastResult;
      } else {
        _setError(data['message'] ?? 'Failed to analyze image.');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Failed to upload and analyze image: $e');
      _setLoading(false);
      return null;
    }
  }

  // Voice AI Detection request (multipart file)
  Future<DetectionModel?> analyzeVoice(String filePath) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _client.postMultipart(
        ApiEndpoints.detectVoice, 
        filePath, 
        'voice',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _lastResult = DetectionModel.fromJson(data);
        _setLoading(false);
        return _lastResult;
      } else {
        _setError(data['message'] ?? 'Failed to analyze audio.');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Failed to upload and analyze audio: $e');
      _setLoading(false);
      return null;
    }
  }
}
