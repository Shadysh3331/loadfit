import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loadfit/core/utils/utils.dart'; // Assuming this contains baseUrl
import 'package:loadfit/features/home/models/AddItemResponse.dart'; // Your AddItemResponse model

class HomeApiManager {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<AddItemResponse> addItem(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/api/basket');
    final token = await _storage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. Please log in first.');
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    // Debugging logs
    print('Add Item Status Code: ${response.statusCode}');
    print('Add Item Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return AddItemResponse.fromJson(responseData);
    } else {
      throw Exception('Failed to add item: ${response.statusCode}');
    }
  }

  Future<void> deleteItem(String itemId) async {
    final url = Uri.parse('$baseUrl/api/basket?id=$itemId');
    final token = await _storage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. Please log in first.');
    }

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // Debugging logs
    print('Delete Status Code: ${response.statusCode}');
    print('Delete Response Body: ${response.body}');

    if (response.statusCode == 200) {
      // Item deleted successfully
    } else {
      throw Exception('Failed to delete item: ${response.statusCode}');
    }
  }
}