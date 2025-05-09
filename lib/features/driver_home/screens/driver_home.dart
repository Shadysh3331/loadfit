import 'package:flutter/material.dart';
import 'package:loadfit/core/utils/color_manager.dart';
import 'package:loadfit/features/driver_home/driver_home_api/driver_api_manager.dart';
import 'package:loadfit/features/driver_home/models/DriverHomeResponse.dart';
import 'package:loadfit/features/vehicleSelection/models/VehicleByIdResponse.dart';
import 'package:loadfit/features/vehicleSelection/models/VehicleResponse.dart';

class DriverMainScreen extends StatefulWidget {
  final VehicleResponse vehicle;

  const DriverMainScreen({
    Key? key,
    required this.vehicle,
  }) : super(key: key);

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  late final DriverApiManager _apiManager;
  List<DriverHomeResponse> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTabIndex = 0; // For filtering orders by status

  @override
  void initState() {
    super.initState();
    _apiManager = DriverApiManager(driverId: widget.vehicle.driverId!);
    _loadDriverOrders();
  }

  Future<void> _loadDriverOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final driverId = widget.vehicle.driverId;
      if (driverId == null) {
        throw Exception('No driver assigned to this vehicle');
      }

      final orders = await _apiManager.getDriverOrders();
      setState(() => _orders = orders);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load orders: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  List<DriverHomeResponse> get _filteredOrders {
    if (_selectedTabIndex == 0) return _orders; // All orders
    final statusFilter = ['Pending', 'In Progress', 'Completed'][_selectedTabIndex - 1];
    return _orders.where((order) => order.status == statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Dashboard - ${widget.vehicle.driverName ?? ''}'),
        backgroundColor: ColorManager.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDriverOrders,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildStatusFilterTabs(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDriverOrders,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildStatusFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterTab('All', 0),
          _buildFilterTab('Pending', 1),
          _buildFilterTab('In Progress', 2),
          _buildFilterTab('Completed', 3),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, int index) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _selectedTabIndex == index
                    ? Colors.white
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _selectedTabIndex == index
                  ? Colors.white
                  : Colors.white.withOpacity(0.7),
              fontWeight: _selectedTabIndex == index
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadDriverOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _filteredOrders.isEmpty
        ? _buildNoOrderView()
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildOrderCard(_filteredOrders[index]),
      ),
    );
  }

  Widget _buildNoOrderView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _selectedTabIndex == 0
                ? 'No orders assigned'
                : 'No ${['Pending', 'In Progress', 'Completed'][_selectedTabIndex - 1].toLowerCase()} orders',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDriverOrders,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(DriverHomeResponse order) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to order details if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Customer', order.buyerEmail ?? 'N/A'),
              _buildDetailRow('Date', order.orderDate ?? 'N/A'),
              if (order.shippingAddress != null) ...[
                _buildDetailRow(
                    'Pickup',
                    order.shippingAddress!.pickupLocation ?? 'N/A'
                ),
                _buildDetailRow(
                    'Destination',
                    order.shippingAddress!.destinationLocation ?? 'N/A'
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'EGP ${order.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}