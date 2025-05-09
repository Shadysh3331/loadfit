import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loadfit/core/utils/utils.dart';
import 'package:loadfit/features/create_order/models/CreateOrderResponse.dart';

class OrderApiManager {
  Future<CreateOrderResponse> createOrder({
    required String basketId,
    required int vehicleId,
    required String name,
    required String pickupLocation,
    required String destinationLocation,
    required String email,
    required String token,
    required String street,
    required String city,
    required String country,
  }) async {
    // Split the name into first and last names
    final nameParts = name.split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Customer';

    final response = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "buyerEmail": email,
        "basketId": basketId,
        "vehicleId": vehicleId,
        "shippingAddress": {
          "firstName": firstName,
          "lastName": lastName,
          "city": city,
          "street": street,
          "country": country,
          "pickupLocation": pickupLocation,
          "destinationLocation": destinationLocation,
        }
      }),
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized - Please login again');
    }

    return _handleResponse<CreateOrderResponse>(
      response,
          (json) => CreateOrderResponse.fromJson(json),
    );
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