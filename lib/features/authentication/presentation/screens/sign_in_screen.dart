import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loadfit/config/routes_manager/routes.dart';
import 'package:loadfit/core/utils/color_manager.dart';
import 'package:loadfit/core/utils/components/custom_elevated_button.dart';
import 'package:loadfit/core/utils/components/main_text_field.dart';
import 'package:loadfit/core/utils/components/validators.dart';
import 'package:loadfit/core/utils/utils.dart';
import 'package:loadfit/core/utils/values_manager.dart';
import 'package:loadfit/features/authentication/auth_api/api_manager.dart';
import 'package:loadfit/features/vehicleSelection/models/VehicleResponse.dart';
import 'package:loadfit/features/vehicleSelection/app_state.dart';
import 'package:loadfit/features/vehicleSelection/storage_service.dart';
import 'package:loadfit/features/vehicleSelection/vehicleSelection_api/vehicle_api_manager.dart';
import 'package:loadfit/features/vehicleSelection/vehicleSelection_api/vehicle_id_api_manager.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final ApiManager _apiManager = ApiManager();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final loginResponse = await _apiManager.login(
          emailController.text,
          passwordController.text
      );

      if (loginResponse.role == 'User') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.userHomeRoute,
              (route) => false,
        );
      } else if (loginResponse.role == 'Driver') {
        final vehicle = await StorageService.getVehicle();

        if (vehicle == null || vehicle.driverId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select a vehicle first'),
              action: SnackBarAction(
                label: 'Select',
                onPressed: () => Navigator.pushNamed(
                  context,
                  Routes.vehicleSelectionRoute,
                ),
              ),
            ),
          );
          return;
        }

        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.driverHomeRoute,
              (route) => false,
          arguments: vehicle, // Pass the saved vehicle
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Sign In"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BuildTextField(
                    controller: emailController,
                    label: "E-mail Address",
                    hint: "Enter your Email Address",
                    textInputType: TextInputType.emailAddress,
                    labelTextStyle: TextStyle(color: Colors.black),
                    validation: AppValidators.validateEmail,
                  ),
                  SizedBox(
                    height: AppSize.s16.h,
                  ),
                  BuildTextField(
                    controller: passwordController,
                    label: "Password",
                    hint: "Enter your Password",
                    labelTextStyle: TextStyle(color: Colors.black),
                    textInputType: TextInputType.text,
                    isObscured: true,
                    validation: AppValidators.validatePassword,
                  ),
                  SizedBox(
                    height: AppSize.s8.h,
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Forget password?',
                          )),
                    ],
                  ),
                  SizedBox(
                    height: AppSize.s60.h,
                  ),
                  _isLoading
                      ? CircularProgressIndicator()
                      : CustomElevatedButton(
                    label: "Login",
                    onTap: _login,
                    isStadiumBorder: false,
                    backgroundColor: ColorManager.black,
                  ),
                  SizedBox(
                    height: AppSize.s28.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(fontSize: 16),
            ),
            InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(context, Routes.signUpRoute, (route) => false);
                },
                child: Text("SignUp", style: TextStyle(fontSize: 18))),
          ],
        ),
      ),
    );
  }
}