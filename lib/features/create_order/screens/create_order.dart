import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loadfit/config/routes_manager/routes.dart';
import 'package:loadfit/features/create_order/create_order_api/order_api_manager.dart';
import 'package:loadfit/features/vehicleSelection/models/VehicleResponse.dart';

class CreateOrderScreen extends StatefulWidget {
  final VehicleResponse vehicle;
  final String pickupLocation;
  final String destinationLocation;
  final String basketId;
  final List<Map<String, dynamic>> items;

  const CreateOrderScreen({
    Key? key,
    required this.vehicle,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.basketId,
    required this.items,
  }) : super(key: key);

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final OrderApiManager _orderApiManager = OrderApiManager();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isFetchingUser = false;
  String? _userEmail;
  String? _userName;
  String? _authToken;

  // Address form controllers
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: 'Egypt');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isFetchingUser = true);
    try {
      final email = await _storage.read(key: 'email');
      final displayName = await _storage.read(key: 'displayName');
      final token = await _storage.read(key: 'token');

      setState(() {
        _userEmail = email;
        _userName = displayName;
        _authToken = token;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load user details: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isFetchingUser = false);
    }
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userName == null || _userEmail == null || _authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Missing required information"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final order = await _orderApiManager.createOrder(
        basketId: widget.basketId,
        vehicleId: widget.vehicle.id!,
        name: _userName!,
        pickupLocation: widget.pickupLocation,
        destinationLocation: widget.destinationLocation,
        email: _userEmail!,
        token: _authToken!,
        street: _streetController.text,
        city: _cityController.text,
        country: _countryController.text,
      );

      Navigator.pushNamed(
        context,
        Routes.paymentRoute,
        arguments: {
          'order': order,
          'clientSecret': order.clientSecret,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create order: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getMaterialName(int? materialType) {
    switch (materialType) {
      case 2500: return 'Glass';
      case 700: return 'Wood';
      case 50: return 'Foam';
      case 950: return 'Plastic';
      default: return 'Unknown';
    }
  }

  String _getFragilityName(int? fragilityType) {
    switch (fragilityType) {
      case 0: return 'Fragile';
      case 1: return 'Non-Fragile';
      default: return 'Unknown';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildLocationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shipping Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Your Items'),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: widget.items.map((item) => ListTile(
                    title: Text(item['name'] ?? 'Unnamed Item'),
                    subtitle: Text(
                      '${item['length']} x ${item['width']} x ${item['height']} cm\n'
                          'Material: ${_getMaterialName(item['material'])}\n'
                          'Fragility: ${_getFragilityName(item['fragility'])}',
                    ),
                  )).toList(),
                ),
              ),
            ),

            _buildSectionHeader('Selected Vehicle'),
            Card(
              elevation: 2,
              child: ListTile(
                leading: widget.vehicle.pictureUrl != null
                    ? Image.network(widget.vehicle.pictureUrl!, width: 60)
                    : const Icon(Icons.directions_car, size: 40),
                title: Text(widget.vehicle.brand ?? 'Vehicle'),
                subtitle: Text(
                  'Type: ${widget.vehicle.type}\n'
                      'Max Weight: ${widget.vehicle.maxWeight} kg\n'
                      'Price: ${widget.vehicle.price?.toStringAsFixed(2)} EGP',
                ),
                trailing: widget.vehicle.isRecommended ?? false
                    ? const Text('⭐ Recommended', style: TextStyle(color: Colors.amber))
                    : null,
              ),
            ),

            _buildSectionHeader('Locations'),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationRow('🚚 Pickup:', widget.pickupLocation),
                    const Divider(),
                    _buildLocationRow('🏁 Destination:', widget.destinationLocation),
                  ],
                ),
              ),
            ),

            _buildSectionHeader('Your Information'),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    if (_isFetchingUser)
                      const CircularProgressIndicator()
                    else ...[
                      _buildUserInfoRow('Name:', _userName ?? 'Not available'),
                      _buildUserInfoRow('Email:', _userEmail ?? 'Not available'),
                    ],
                  ],
                ),
              ),
            ),

            _buildAddressForm(),

            const SizedBox(height: 20),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _createOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm Order',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}