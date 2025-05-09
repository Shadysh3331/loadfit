import 'package:flutter/material.dart';
import 'package:loadfit/config/routes_manager/routes.dart';
import 'package:loadfit/core/utils/components/custom_elevated_button.dart';
import 'package:loadfit/features/vehicleSelection/app_state.dart';
import 'package:loadfit/features/vehicleSelection/storage_service.dart';
import '../../models/VehicleResponse.dart';
import '../../vehicleSelection_api/vehicle_api_manager.dart';

class VehicleSelectionScreen extends StatefulWidget {
  final String basketId;
  final List<Map<String, dynamic>> items;

  const VehicleSelectionScreen({
    Key? key,
    required this.basketId,
    required this.items,
  }) : super(key: key);

  @override
  _VehicleSelectionScreenState createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  final VehicleApiManager _apiManager = VehicleApiManager();
  List<VehicleResponse> vehicles = [];
  List<VehicleResponse> filteredVehicles = [];
  VehicleResponse? selectedVehicle;
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();

  // Sorting variables
  String? _sortBy; // null, 'price', or 'brand'
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    try {
      final loadedVehicles = await _apiManager.getVehicles(widget.basketId);
      setState(() {
        vehicles = loadedVehicles;
        filteredVehicles = loadedVehicles;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load vehicles: $e';
        isLoading = false;
      });
    }
  }

  void _filterVehicles(String query) {
    setState(() {
      filteredVehicles = vehicles.where((vehicle) {
        final brand = vehicle.brand?.toLowerCase() ?? '';
        return brand.contains(query.toLowerCase());
      }).toList();
      if (_sortBy != null) _sortVehicles();
    });
  }

  void _sortVehicles() {
    setState(() {
      filteredVehicles.sort((a, b) {
        int compareResult;
        if (_sortBy == 'price') {
          final priceA = a.price ?? 0;
          final priceB = b.price ?? 0;
          compareResult = priceA.compareTo(priceB);
        } else {
          final brandA = a.brand?.toLowerCase() ?? '';
          final brandB = b.brand?.toLowerCase() ?? '';
          compareResult = brandA.compareTo(brandB);
        }
        return _ascending ? compareResult : -compareResult;
      });
    });
  }

  void _handleSortOptionSelected(String? value) {
    if (value == null) return;

    setState(() {
      if (_sortBy == value) {
        // Toggle direction if same sort option is selected
        _ascending = !_ascending;
      } else {
        // Change sort field and reset to ascending
        _sortBy = value;
        _ascending = true;
      }
      _sortVehicles();
    });
  }

  void selectVehicle(VehicleResponse vehicle) {
    setState(() {
      selectedVehicle = vehicle;
    });
  }

  void _showErrorMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please select a vehicle before confirming.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select a Vehicle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Sort Row
            Row(
              children: [
                // Search Field
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by brand...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: _filterVehicles,
                  ),
                ),
                SizedBox(width: 10),
                // Sort Dropdown with Direction Indicator
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sort Dropdown
                      PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'price',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: 8),
                                Text('Price'),
                                if (_sortBy == 'price')
                                  Icon(
                                    _ascending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: Colors.blueAccent,
                                    size: 16,
                                  ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'brand',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: 8),
                                Text('Brand'),
                                if (_sortBy == 'brand')
                                  Icon(
                                    _ascending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: Colors.blueAccent,
                                    size: 16,
                                  ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: _handleSortOptionSelected,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort,
                                color: Colors.blueAccent,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _sortBy == null
                                    ? 'Sort by'
                                    : _sortBy == 'price'
                                    ? 'Price'
                                    : 'Brand',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_sortBy != null) ...[
                                SizedBox(width: 4),
                                Icon(
                                  _ascending
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: Colors.blueAccent,
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Center(child: Text(errorMessage!))
            else if (filteredVehicles.isEmpty)
                Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'No vehicles available for your items.'
                        : 'No vehicles found for "${_searchController.text}"',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = filteredVehicles[index];
                      return GestureDetector(
                        onTap: () => selectVehicle(vehicle),
                        child: Card(
                          color: selectedVehicle?.id == vehicle.id
                              ? Colors.blue[100]
                              : Colors.grey[200],
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Stack(
                              children: [
                                if (vehicle.isRecommended ?? false)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Recommended',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (vehicle.pictureUrl != null)
                                      Image.network(
                                        vehicle.pictureUrl!,
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 150,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                              Icons.image_not_supported),
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    Center(
                                      child: Text(
                                        vehicle.brand ?? 'No Brand',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Center(
                                      child: Text(
                                        'Type: ${vehicle.type ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        'Max Weight: ${vehicle.maxWeight?.toString() ?? 'N/A'} kg',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        'Price: ${vehicle.price?.toStringAsFixed(2) ?? 'N/A'} EGP',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            Routes.vehicleDetailsRoute,
                                            arguments: {
                                              'vehicle': vehicle,
                                              'basketId': widget.basketId,
                                              'items': widget.items,
                                            },
                                          );
                                        },
                                        child: const Text(
                                          'Details >',
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            const SizedBox(height: 20),
            Center(
              child: CustomElevatedButton(
                backgroundColor: Colors.blueAccent,
                label: "Confirm",
                onTap: selectedVehicle == null
                    ? () => _showErrorMessage(context)
                    : () async{
                  await StorageService.saveVehicle(selectedVehicle!);

                  Navigator.pushNamed(
                    context,
                    Routes.locationRoute,
                    arguments: {
                      'vehicle': selectedVehicle!,
                      'basketId': widget.basketId,
                      'items': widget.items,
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}