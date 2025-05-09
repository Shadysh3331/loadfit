// storage_service.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loadfit/features/vehicleSelection/models/VehicleResponse.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveVehicle(VehicleResponse vehicle) async {
    await _storage.write(
        key: 'currentVehicle',
        value: jsonEncode(vehicle.toJson())
    );
  }

  static Future<VehicleResponse?> getVehicle() async {
    final vehicleJson = await _storage.read(key: 'currentVehicle');
    return vehicleJson != null
        ? VehicleResponse.fromJson(jsonDecode(vehicleJson))
        : null;
  }

  static Future<void> clearVehicle() async {
    await _storage.delete(key: 'currentVehicle');
  }
}