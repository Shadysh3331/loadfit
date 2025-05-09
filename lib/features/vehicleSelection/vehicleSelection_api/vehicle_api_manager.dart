import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loadfit/core/utils/utils.dart';
import '../models/VehicleResponse.dart';

class VehicleApiManager {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<VehicleResponse>> getVehicles(String basketId) async {
    final url = Uri.parse('$baseUrl/api/Vehicles?basketId=$basketId');
    final token = await _storage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. Please log in first.');
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('Get Vehicles Status Code: ${response.statusCode}');
    print('Get Vehicles Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((vehicle) => VehicleResponse.fromJson(vehicle)).toList();
    } else {
      throw Exception('Failed to load vehicles: ${response.statusCode}');
    }
  }
}