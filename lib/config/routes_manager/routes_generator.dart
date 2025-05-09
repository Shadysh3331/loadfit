import 'package:flutter/material.dart';
import 'package:loadfit/config/routes_manager/routes.dart';
import 'package:loadfit/features/authentication/presentation/screens/sign_in_screen.dart';
import 'package:loadfit/features/authentication/presentation/screens/sign_up_screen.dart';
import 'package:loadfit/features/driver_home/screens/driver_home.dart';
import 'package:loadfit/features/home/presentation/screens/user_home_screen.dart';
import 'package:loadfit/features/location/presentation/screens/location.dart';
import 'package:loadfit/features/order_details/screens/order_details.dart';
import 'package:loadfit/features/payment/screens/payment.dart';
import 'package:loadfit/features/vehicleSelection/models/VehicleByIdResponse.dart';
import 'package:loadfit/features/vehicleSelection/presentation/screens/vehicle_details.dart';
import 'package:loadfit/features/vehicleSelection/presentation/screens/vehicleselection.dart';

import '../../features/create_order/screens/create_order.dart';
import '../../features/vehicleSelection/models/VehicleResponse.dart';

class RoutesGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.signInRoute:
        return MaterialPageRoute(builder: (context) => SignInScreen());
      case Routes.signUpRoute:
        return MaterialPageRoute(builder: (context) => SignUpScreen());
      case Routes.userHomeRoute:
        return MaterialPageRoute(builder: (context) => ServiceAndDimensionsScreen());
      case Routes.locationRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LocationSearchScreen(
            vehicle: args['vehicle'] as VehicleResponse,
            basketId: args['basketId'] as String,
            items: args['items'] as List<Map<String, dynamic>>,
          ),
        );
      case Routes.vehicleSelectionRoute:
        final args = settings.arguments as Map<String, dynamic>;
        if (args != null) {
          return MaterialPageRoute(
            builder: (context) => VehicleSelectionScreen(
              basketId: args['basketId'] as String,
              items: args['items'] as List<Map<String, dynamic>>,
            ),
          );
        } else {
          return _errorRoute('Basket ID is required for vehicle selection');
        }
      case Routes.vehicleDetailsRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => VehicleDetailsScreen(
            vehicle: args['vehicle'] as VehicleResponse,
            basketId: args['basketId'] as String,
            items: args['items'] as List<Map<String, dynamic>>,
          ),
        );
      case Routes.createOrderRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CreateOrderScreen(
            vehicle: args['vehicle'] as VehicleResponse,
            pickupLocation: args['pickupAddress'] as String,
            destinationLocation: args['destinationAddress'] as String,
            basketId: args['basketId'] as String,
            items: args['items'] as List<Map<String, dynamic>>,
          ),
        );
      case Routes.paymentRoute:
        return MaterialPageRoute(builder: (context) => PaymentScreen());
      case Routes.driverHomeRoute:
        final vehicle = settings.arguments as VehicleResponse;
        return MaterialPageRoute(
          builder: (context) => DriverMainScreen(
            vehicle: vehicle,
          ),
        );
      case Routes.orderDetailsRoute:
        final order = settings.arguments as Map<String, dynamic>?;
        if (order != null) {
          return MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          );
        } else {
          return unDefinedRoute(); // Handle null case
        }
      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('No Route Found'),
        ),
        body: const Center(child: Text('No Route Found')),
      ),
    );
  }
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(child: Text(message)),
      ),
    );
  }
}