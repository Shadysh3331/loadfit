import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loadfit/core/utils/utils.dart';
import 'package:loadfit/features/driver_home/models/DriverHomeResponse.dart';

class DriverApiManager {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final int driverId;

  // No need to require driverId in constructor since we'll get it from vehicle
  DriverApiManager({required this.driverId});

  Future<List<DriverHomeResponse>> getDriverOrders() async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('No authentication token found');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/driver-orders/$driverId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DriverHomeResponse.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return []; // No orders found
      } else {
        throw Exception('Failed to load orders: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch orders: ${e.toString()}');
    }
  }
}