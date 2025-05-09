// current_user_api_manager.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loadfit/core/utils/utils.dart';
import 'package:loadfit/features/authentication/models/CurrentUserResponse.dart';

class CurrentUserApiManager {

  Future<CurrentUserResponse> getCurrentUser(String? token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/account'),
      headers: _buildHeaders(token),
    );

    return _handleResponse<CurrentUserResponse>(
      response,
          (json) => CurrentUserResponse.fromJson(json),
    );
  }

  Map<String, String> _buildHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  T _handleResponse<T>(http.Response response, T Function(dynamic) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Request failed with status: ${response.statusCode}. '
            'Message: ${response.body}',
      );
    }
  }
}