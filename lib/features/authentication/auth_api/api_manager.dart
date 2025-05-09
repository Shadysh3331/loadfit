import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loadfit/core/utils/utils.dart';
import 'package:loadfit/features/authentication/models/ErrorResponse.dart';
import 'package:loadfit/features/authentication/models/SignInResponse.dart';
import 'package:loadfit/features/authentication/models/SignUpResponse.dart';

class ApiManager {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<SignInResponse> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/account/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final loginResponse = SignInResponse.fromJson(responseData);
      await _storage.write(key: 'token', value: loginResponse.token!);
      await _storage.write(key: 'email', value: email);
      if (loginResponse.displayName != null) {
        await _storage.write(key: 'displayName', value: loginResponse.displayName!);
      }
      return loginResponse;
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<SignUpResponse> signUp(Map<String, dynamic> requestBody) async {
    final url = Uri.parse('$baseUrl/api/account/register');


    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('====== RESPONSE ======');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('======================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SignUpResponse.fromJson(responseData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('errors')) {
            final errors = List<String>.from(errorData['errors'] ?? []);
            throw Exception(errors.isNotEmpty ? errors.join('\n') : 'Registration failed');
          }
          throw Exception(errorData['message'] ?? 'Registration failed');
        } catch (e) {
          throw Exception('Failed to parse error: ${response.body}');
        }
      }
    } catch (e) {
      print('!!!!!!! ERROR !!!!!!!');
      print(e.toString());
      print('!!!!!!!!!!!!!!!!!!!!!');
      rethrow;
    }
  }

// Future<List<BrandResponse>> fetchBrands() async {
//   final url = Uri.parse('$baseUrl/api/Vehicles/brands');
//   final response = await http.get(
//     url,
//     headers: {
//       'Authorization': 'Bearer $hardCodedToken',
//     },
//   );
//
//   print('Brands Status Code: ${response.statusCode}');
//   print('Brands Response Body: ${response.body}');
//
//   if (response.statusCode == 200) {
//     final List<dynamic> responseData = jsonDecode(response.body);
//     return responseData.map((brand) => BrandResponse.fromJson(brand)).toList();
//   } else {
//     throw Exception('Failed to fetch brands: ${response.statusCode}');
//   }
// }
//
// Future<List<TypeResponse>> fetchTypes() async {
//   final url = Uri.parse('$baseUrl/api/Vehicles/types');
//   final response = await http.get(
//     url,
//     headers: {
//       'Authorization': 'Bearer $hardCodedToken',
//     },
//   );
//
//   print('Types Status Code: ${response.statusCode}');
//   print('Types Response Body: ${response.body}');
//
//   if (response.statusCode == 200) {
//     final List<dynamic> responseData = jsonDecode(response.body);
//     return responseData.map((type) => TypeResponse.fromJson(type)).toList();
//   } else {
//     throw Exception('Failed to fetch types: ${response.statusCode}');
//   }
// }
}