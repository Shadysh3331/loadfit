import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loadfit/features/vehicleSelection/models/VehicleResponse.dart';
import 'package:location/location.dart';
import 'package:loadfit/config/routes_manager/routes.dart';

class LocationSearchScreen extends StatefulWidget {
  final VehicleResponse vehicle;
  final String basketId;
  final List<Map<String, dynamic>> items;

  const LocationSearchScreen({
    Key? key,
    required this.vehicle,
    required this.basketId,
    required this.items,
  }) : super(key: key);

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  StreamSubscription<LocationData>? _locationSubscription;
  final Completer<GoogleMapController> _mapController = Completer();
  Location _locationService = Location();
  GoogleMapController? _googleMapController;

  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(30.0444, 31.2357),
    zoom: 15,
  );

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;
  bool _isRouteLoading = false;

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<dynamic> _pickupSuggestions = [];
  List<dynamic> _destinationSuggestions = [];
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  bool _showPickupSuggestions = false;
  bool _showDestinationSuggestions = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _pickupController.dispose();
    _destinationController.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) throw 'Location services disabled';
      }

      PermissionStatus permission = await _locationService.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _locationService.requestPermission();
        if (permission != PermissionStatus.granted) {
          throw 'Location permissions denied';
        }
      }

      LocationData locationData = await _locationService.getLocation();
      final currentLocation = LatLng(
        locationData.latitude ?? _initialCameraPosition.target.latitude,
        locationData.longitude ?? _initialCameraPosition.target.longitude,
      );

      setState(() {
        _initialCameraPosition = CameraPosition(
          target: currentLocation,
          zoom: 15,
        );
        _isLoading = false;
      });

      _locationSubscription = _locationService.onLocationChanged.listen((LocationData locationData) {
        if (_googleMapController != null && _pickupLocation == null && _destinationLocation == null) {
          _googleMapController?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(locationData.latitude!, locationData.longitude!),
            ),
          );
        }
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Locations', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildLocationInputField(
            controller: _pickupController,
            hintText: 'Pickup Location',
            suggestions: _pickupSuggestions,
            isPickup: true,
            showSuggestions: _showPickupSuggestions,
          ),
          _buildLocationInputField(
            controller: _destinationController,
            hintText: 'Destination Location',
            suggestions: _destinationSuggestions,
            isPickup: false,
            showSuggestions: _showDestinationSuggestions,
          ),
          if (_isRouteLoading)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (controller) {
                _mapController.complete(controller);
                _googleMapController = controller;
                if (_initialCameraPosition.target != LatLng(30.0444, 31.2357)) {
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(_initialCameraPosition),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildContinueButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInputField({
    required TextEditingController controller,
    required String hintText,
    required List<dynamic> suggestions,
    required bool isPickup,
    required bool showSuggestions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(isPickup ? Icons.location_on : Icons.flag),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                _fetchLocationSuggestions(value, isPickup);
                setState(() {
                  if (isPickup) {
                    _showPickupSuggestions = true;
                  } else {
                    _showDestinationSuggestions = true;
                  }
                });
              } else {
                setState(() {
                  if (isPickup) {
                    _showPickupSuggestions = false;
                  } else {
                    _showDestinationSuggestions = false;
                  }
                });
              }
            },
            onTap: () {
              setState(() {
                if (isPickup) {
                  _showPickupSuggestions = true;
                } else {
                  _showDestinationSuggestions = true;
                }
              });
            },
          ),
          if (showSuggestions && suggestions.isNotEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final place = suggestions[index];
                  return ListTile(
                    title: Text(place['display_name'] ?? 'Unnamed Location'),
                    dense: true,
                    onTap: () {
                      _onPlaceSelected(place, isPickup);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _pickupLocation != null && _destinationLocation != null
            ? _navigateToCreateOrderScreen
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _fetchLocationSuggestions(String query, bool isPickup) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5'),
        headers: {
          'User-Agent': 'LoadFit/1.0'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> places = json.decode(response.body);
        setState(() {
          if (isPickup) {
            _pickupSuggestions = places;
          } else {
            _destinationSuggestions = places;
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch locations: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch locations: $e')),
      );
    }
  }

  Future<void> _onPlaceSelected(dynamic place, bool isPickup) async {
    try {
      final lat = place['lat'] is num ? place['lat'].toDouble()
          : double.tryParse(place['lat']?.toString() ?? '');
      final lon = place['lon'] is num ? place['lon'].toDouble()
          : double.tryParse(place['lon']?.toString() ?? '');

      if (lat == null || lon == null) {
        throw Exception('Invalid location coordinates');
      }

      final location = LatLng(lat, lon);
      final displayName = place['display_name']?.toString() ?? 'Selected Location';

      setState(() {
        if (isPickup) {
          _pickupLocation = location;
          _pickupController.text = displayName;
          _showPickupSuggestions = false;
        } else {
          _destinationLocation = location;
          _destinationController.text = displayName;
          _showDestinationSuggestions = false;
        }
      });

      _updateMarkers();

      if (_googleMapController != null) {
        if (_pickupLocation != null && _destinationLocation != null) {
          setState(() => _isRouteLoading = true);
          await _updateRoutePolyline();
          setState(() => _isRouteLoading = false);

          final bounds = LatLngBounds(
            southwest: LatLng(
              min(_pickupLocation!.latitude, _destinationLocation!.latitude),
              min(_pickupLocation!.longitude, _destinationLocation!.longitude),
            ),
            northeast: LatLng(
              max(_pickupLocation!.latitude, _destinationLocation!.latitude),
              max(_pickupLocation!.longitude, _destinationLocation!.longitude),
            ),
          );

          _googleMapController!.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 100),
          );
        } else {
          _googleMapController!.animateCamera(
            CameraUpdate.newLatLngZoom(location, 15),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting location: ${e.toString()}')),
      );
    }
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    if (_pickupLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Pickup Location',
          snippet: _pickupController.text,
        ),
      ));
    }

    if (_destinationLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: _destinationController.text,
        ),
      ));
    }

    setState(() {
      _markers = markers;
    });
  }

  Future<void> _updateRoutePolyline() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/'
              '${_pickupLocation!.longitude},${_pickupLocation!.latitude};'
              '${_destinationLocation!.longitude},${_destinationLocation!.latitude}'
              '?overview=full&geometries=geojson',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok') {
          final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
          final points = coordinates
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();

          setState(() {
            _polylines = {
              Polyline(
                polylineId: const PolylineId('route'),
                points: points,
                color: Colors.blue,
                width: 4,
              ),
            };
          });
        }
      } else {
        throw Exception('Failed to get route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error drawing route: $e');
      // Fallback to straight line if OSRM fails
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [_pickupLocation!, _destinationLocation!],
            color: Colors.blue,
            width: 4,
          ),
        };
      });
    }
  }

  void _navigateToCreateOrderScreen() {
    if (widget.vehicle.id == null || widget.vehicle.id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid vehicle selection'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_pickupController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both pickup and destination locations'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      Routes.createOrderRoute,
      arguments: {
        'vehicle': widget.vehicle,
        'pickupAddress': _pickupController.text,
        'destinationAddress': _destinationController.text,
        'basketId': widget.basketId,
        'items': widget.items,
      },
    );
  }
}