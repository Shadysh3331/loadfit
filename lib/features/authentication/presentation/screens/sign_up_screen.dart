import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loadfit/config/routes_manager/routes.dart';
import 'package:loadfit/core/utils/color_manager.dart';
import 'package:loadfit/core/utils/components/custom_elevated_button.dart';
import 'package:loadfit/core/utils/components/main_text_field.dart';
import 'package:loadfit/core/utils/components/validators.dart';
import 'package:loadfit/features/authentication/auth_api/api_manager.dart';
import 'package:loadfit/features/authentication/models/SignUpResponse.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var licenseNumberController = TextEditingController();
  var carNameController = TextEditingController();
  var carDescriptionController = TextEditingController();
  var carPriceController = TextEditingController();
  var carMaxWeightController = TextEditingController();
  var carLengthController = TextEditingController();
  var carWidthController = TextEditingController();
  var carHeightController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String _role = 'User';
  File? _carImage;
  final ImagePicker _picker = ImagePicker();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  final ApiManager _apiManager = ApiManager();
  // List<BrandResponse> _brands = [];
  // List<TypeResponse> _types = [];
  // int? _selectedBrandId;
  // int? _selectedTypeId;

  @override
  void initState() {
    super.initState();
    // _fetchBrandsAndTypes();
  }

  // Future<void> _fetchBrandsAndTypes() async {
  //   try {
  //     final brands = await _apiManager.fetchBrands();
  //     final types = await _apiManager.fetchTypes();
  //     setState(() {
  //       _brands = brands;
  //       _types = types;
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to fetch brands and types: $e')),
  //     );
  //   }
  // }

  Future<void> _pickCarImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _carImage = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
    }
  }

  Future<String?> _uploadImageToImgBB(File imageFile) async {
    const apiKey = 'd2ff5138643a7ae81e2e8435cedd8738';
    const uploadUrl = 'https://api.imgbb.com/1/upload';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['key'] = apiKey
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        return jsonResponse['data']['url'];
      } else {
        throw 'Failed to upload image: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error uploading image: $e';
    }
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) {
      // If any field is invalid, stop the signup process.
      return;
    }

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    String? carImageUrl;
    if (_role == 'Driver' && _carImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload a car image')),
      );
      return;
    }

    if (_carImage != null) {
      try {
        carImageUrl = await _uploadImageToImgBB(_carImage!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload car image: $e')),
        );
        return;
      }
    }

    final requestBody = {
      'displayName': nameController.text,
      'email': emailController.text,
      'phoneNumber': phoneNumberController.text,
      'password': passwordController.text,
      'role': _role,
      if (_role == 'Driver') ...{
        'licenseNumber': licenseNumberController.text,
        'vehicle': {
          'name': carNameController.text,
          'description': carDescriptionController.text,
          'pictureUrl': carImageUrl??"",
          'price': double.tryParse(carPriceController.text),
          'maxWeight': double.tryParse(carMaxWeightController.text)?.toInt(),
          'length': double.tryParse(carLengthController.text),
          'width': double.tryParse(carWidthController.text),
          'height': double.tryParse(carHeightController.text),
          // 'brandId': _selectedBrandId,
          // 'typeId': _selectedTypeId,
        },
      },
    };

    print('Request Body: ${jsonEncode(requestBody)}');
    try {
      final signUpResponse = await _apiManager.signUp(requestBody);
      await _storage.write(key: 'token', value: signUpResponse.token!);

      Navigator.pushNamedAndRemoveUntil(
          context,
          _role == 'Driver' ? Routes.driverHomeRoute : Routes.userHomeRoute,
              (route) => false
      );
    } catch (e) {
      String errorMessage = 'Signup failed';

      if (e.toString().contains('email already exists')) {
        errorMessage = 'This email is already registered';
      }
      else if (e.toString().contains('password')) {
        errorMessage = 'Password must be at least 8 characters';
      }
      else if (e.toString().contains('phone number')) {
        errorMessage = 'Invalid phone number format';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _role,
                  items: ['User', 'Driver']
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _role = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Role'),
                ),
                SizedBox(height: 16),
                BuildTextField(
                  controller: nameController,
                  label: "Name",
                  labelTextStyle: TextStyle(color: Colors.black),
                  hint: "Enter your name",
                  validation: AppValidators.validateFullName,
                ),
                SizedBox(height: 10),
                BuildTextField(
                  controller: emailController,
                  label: "E-mail Address",
                  hint: "Enter your Email Address",
                  textInputType: TextInputType.emailAddress,
                  labelTextStyle: TextStyle(color: Colors.black),
                  validation: AppValidators.validateEmail,
                ),
                SizedBox(height: 10),
                BuildTextField(
                  controller: passwordController,
                  label: "Password",
                  hint: "Enter your Password",
                  labelTextStyle: TextStyle(color: Colors.black),
                  textInputType: TextInputType.text,
                  isObscured: true,
                  validation: AppValidators.validatePassword,
                ),
                SizedBox(height: 10),
                BuildTextField(
                  controller: phoneNumberController,
                  label: "Phone Number",
                  labelTextStyle: TextStyle(color: Colors.black),
                  hint: "Enter your phone number",
                  validation: AppValidators.validatePhoneNumber,
                ),
                SizedBox(height: 10),
                if (_role == 'Driver') ...[
                  BuildTextField(
                    controller: licenseNumberController,
                    label: "Driver License Number",
                    labelTextStyle: TextStyle(color: Colors.black),
                    hint: "Enter your driver license number",
                  ),
                  SizedBox(height: 10),
                  BuildTextField(
                    controller: carNameController,
                    label: "Car Name",
                    labelTextStyle: TextStyle(color: Colors.black),
                    hint: "Enter car name",
                  ),
                  SizedBox(height: 10),
                  BuildTextField(
                    controller: carDescriptionController,
                    label: "Car Description",
                    labelTextStyle: TextStyle(color: Colors.black),
                    hint: "Enter car description",
                  ),
                  SizedBox(height: 10),
                  BuildTextField(
                    controller: carPriceController,
                    label: "Car Price",
                    labelTextStyle: TextStyle(color: Colors.black),
                    hint: "Enter car price",
                  ),
                  SizedBox(height: 10),
                  BuildTextField(
                    controller: carMaxWeightController,
                    label: "Car Max Weight (kg)",
                    labelTextStyle: TextStyle(color: Colors.black),
                    hint: "Enter car max weight",
                    validation: AppValidators.validateCarMaxWeight,
                  ),
                  SizedBox(height: 10),
                  BuildTextField(
                    controller: carLengthController,
                    label: "Car Length",
                    labelTextStyle: TextStyle(color: Colors.black),
                    hint: "Enter car length",
                  ),
                  SizedBox(height: 10),
                  BuildTextField(
                    controller: carWidthController,
                    label: "Car Width",
                    labelTextStyle: TextStyle(color: Colors.black),
                    hint: "Enter car width",
                  ),
                  SizedBox(height: 10),
                  BuildTextField(
                    controller: carHeightController,
                    label: "Car Height",
                    labelTextStyle: TextStyle(color: Colors.black),
                    hint: "Enter car height",
                  ),
                  // SizedBox(height: 10),
                  // DropdownButtonFormField<int>(
                  //   value: _selectedBrandId,
                  //   items: _brands
                  //       .map((brand) => DropdownMenuItem(
                  //     value: brand.id,
                  //     child: Text(brand.name ?? ''),
                  //   ))
                  //       .toList(),
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _selectedBrandId = value;
                  //     });
                  //   },
                  //   decoration: InputDecoration(labelText: 'Brand'),
                  // ),
                  // SizedBox(height: 10),
                  // DropdownButtonFormField<int>(
                  //   value: _selectedTypeId,
                  //   items: _types
                  //       .map((type) => DropdownMenuItem(
                  //     value: type.id,
                  //     child: Text(type.name ?? ''),
                  //   ))
                  //       .toList(),
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _selectedTypeId = value;
                  //     });
                  //   },
                  //   decoration: InputDecoration(labelText: 'Type'),
                  // ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickCarImage,
                    child: Text('Upload Car Image'),
                  ),
                  SizedBox(height: 10),
                  if (_carImage != null)
                    Image.file(
                      _carImage!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                ],
                SizedBox(height: 10),
                Center(
                  child: CustomElevatedButton(
                    label: "Sign Up",
                    onTap: _signUp,
                    isStadiumBorder: false,
                    backgroundColor: ColorManager.black,
                  ),
                ),
              ],
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
              "I have an account?",
              style: TextStyle(fontSize: 20),
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.signInRoute,
                      (route) => false,
                );
              },
              child: Text(
                " Login",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}