import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loadfit/config/routes_manager/routes.dart';
import 'package:loadfit/core/utils/components/custom_elevated_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../models/VehicleResponse.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final VehicleResponse vehicle;
  final String basketId;
  final List<Map<String, dynamic>> items;

  const VehicleDetailsScreen(
      {Key? key,
      required this.vehicle,
      required this.basketId,
      required this.items})
      : super(key: key);

  @override
  _VehicleDetailsScreenState createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vehicle Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCarousel(),
              const SizedBox(height: 20),
              _buildDriverInfo(),
              const SizedBox(height: 20),
              _buildVehicleSpecs(),
              const SizedBox(height: 20),
              _buildDescriptionSection(),
              const SizedBox(height: 20),
              _buildConfirmButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            enlargeCenterPage: true,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() => _currentImageIndex = index);
            },
          ),
          items: [
            if (widget.vehicle.pictureUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.vehicle.pictureUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                  loadingBuilder: (_, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                color: Colors.grey[200],
                height: 200,
                child: const Center(
                  child:
                      Icon(Icons.directions_car, size: 50, color: Colors.grey),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (widget.vehicle.pictureUrl != null)
          AnimatedSmoothIndicator(
            activeIndex: _currentImageIndex,
            count: 1,
            effect: const WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Colors.blueAccent,
              dotColor: Colors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.vehicle.driverName ?? 'Driver Information',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleSpecs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehicle Specifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow('Brand', widget.vehicle.brand ?? 'N/A'),
        _buildDetailRow('Model', widget.vehicle.model ?? 'N/A'),
        _buildDetailRow('Type', widget.vehicle.type ?? 'N/A'),
        _buildDetailRow(
          'Dimensions',
          '${widget.vehicle.length?.toStringAsFixed(2) ?? 'N/A'}m (L) × '
              '${widget.vehicle.width?.toStringAsFixed(2) ?? 'N/A'}m (W) × '
              '${widget.vehicle.height?.toStringAsFixed(2) ?? 'N/A'}m (H)',
        ),
        _buildDetailRow(
            'Max Weight', '${widget.vehicle.maxWeight ?? 'N/A'} kg'),
        _buildDetailRow('Price',
            '${widget.vehicle.price?.toStringAsFixed(2) ?? 'N/A'} EGP'),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.vehicle.description ?? 'No description available',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Center(
      child: CustomElevatedButton(
        backgroundColor: Colors.blueAccent,
        label: "Confirm Vehicle",
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.locationRoute,
            arguments: {
              'vehicle': widget.vehicle,
              'basketId': widget.basketId,
              'items': widget.items,
            });
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
