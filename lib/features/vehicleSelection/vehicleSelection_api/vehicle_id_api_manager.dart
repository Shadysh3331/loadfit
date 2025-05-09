import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loadfit/core/utils/utils.dart';
import 'package:loadfit/features/vehicleSelection/models/VehicleByIdResponse.dart';

class VehicleIdApiManager {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<VehicleByIdResponse> getVehicleById(int vehicleId) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/Vehicles/$vehicleId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return VehicleByIdResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Vehicle not found with ID: $vehicleId');
      } else {
        throw Exception(
            'Failed to load vehicle. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch vehicle: ${e.toString()}');
    }
  }

}