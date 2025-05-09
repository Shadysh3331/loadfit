import 'package:loadfit/features/vehicleSelection/models/VehicleResponse.dart';

// app_state.dart
class AppState {
  static VehicleResponse? _currentVehicle;

  static void setCurrentVehicle(VehicleResponse vehicle) {
    _currentVehicle = vehicle;
  }

  static VehicleResponse? getCurrentVehicle() {
    return _currentVehicle;
  }

  static void clearVehicle() {
    _currentVehicle = null;
  }
}
