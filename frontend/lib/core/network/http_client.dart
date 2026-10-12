import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HttpClient {
  final _storage = const FlutterSecureStorage();
  final http.Client _client = http.Client();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<Map<String, String>> _getHeaders({bool isJson = true}) async {
    final headers = <String, String>{};
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    
    final token = await _getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // HTTP GET
  Future<http.Response> get(String url) async {
    final headers = await _getHeaders();
    return await _client.get(Uri.parse(url), headers: headers);
  }

  // HTTP POST (JSON body)
  Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await _client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // HTTP DELETE
  Future<http.Response> delete(String url) async {
    final headers = await _getHeaders();
    return await _client.delete(Uri.parse(url), headers: headers);
  }

  // Multipart File POST (Used for image/voice uploads)
  Future<http.Response> postMultipart(
    String url, 
    String filePath, 
    String fieldName,
  ) async {
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);
    
    // Inject auth header
    final authHeaders = await _getHeaders(isJson: false);
    request.headers.addAll(authHeaders);
    
    // Attach file
    final file = await http.MultipartFile.fromPath(fieldName, filePath);
    request.files.add(file);
    
    // Send and parse response
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
