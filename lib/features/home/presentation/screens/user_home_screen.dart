import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loadfit/config/routes_manager/routes.dart';
import 'package:loadfit/features/home/home_api/home_api_manager.dart';
import 'package:uuid/uuid.dart';

class ServiceAndDimensionsScreen extends StatefulWidget {
  @override
  _ServiceAndDimensionsScreenState createState() =>
      _ServiceAndDimensionsScreenState();
}

class _ServiceAndDimensionsScreenState
    extends State<ServiceAndDimensionsScreen> {
  final nameController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  String selectedFragility = 'Fragile';
  String selectedMaterial = 'Glass';

  List<Map<String, dynamic>> items = [];
  String? basketId;

  final HomeApiManager _apiManager = HomeApiManager();

  void addItem() async {
    if (nameController.text.isEmpty ||
        lengthController.text.isEmpty ||
        widthController.text.isEmpty ||
        heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Generate a random UUID for the Id field
      final uuid = Uuid();
      basketId = basketId ?? uuid.v4(); // v4 generates a random UUID

      // Construct the request payload
      final requestPayload = {
        "id": basketId, // Use the generated UUID
        "items": [
          {
            "id": 1,
            // Replace with a unique ID for the item
            "name": nameController.text,
            "length": int.parse(lengthController.text),
            // Convert to integer
            "width": int.parse(widthController.text),
            // Convert to integer
            "height": int.parse(heightController.text),
            // Convert to integer
            "materialType": _getMaterialTypeEnum(selectedMaterial),
            // Use helper method
            "fragilityType": _getFragilityTypeEnum(selectedFragility),
            // Use helper method
            "quantity": 1,
            // Default quantity
          }
        ],
      };

      // Debugging: Print the payload
      print('Request Payload: ${jsonEncode(requestPayload)}');

      final addItemResponse = await _apiManager.addItem(requestPayload);

      // Access the first item in the response
      final item = addItemResponse.items?.first;

      if (item != null) {
        setState(() {
          items.add({
            'id': item.id, // Store the item ID for deletion
            'name': item.name,
            'length': item.length,
            'width': item.width,
            'height': item.height,
            'material': item.materialType,
            'fragility': item.fragilityType,
          });
        });

        nameController.clear();
        lengthController.clear();
        widthController.clear();
        heightController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No item found in the response"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add item: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _getMaterialTypeEnum(String materialType) {
    switch (materialType) {
      case 'Glass':
        return 2500; // Replace with the correct value
      case 'Wood':
        return 700; // Replace with the correct value
      case 'foam':
        return 50; // Replace with the correct value
      case 'Plastic':
        return 950; // Replace with the correct value
      default:
        throw Exception('Invalid material type: $materialType');
    }
  }

  int _getFragilityTypeEnum(String fragilityType) {
    switch (fragilityType) {
      case 'Fragile':
        return 0; // Replace with the correct value
      case 'Non-Fragile':
        return 1; // Replace with the correct value
      default:
        throw Exception('Invalid fragility type: $fragilityType');
    }
  }

  void removeItem(int index) async {
    final itemId = items[index]['id']; // Retrieve the item ID
    if (itemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Item ID is missing"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Convert itemId to string if it's not already
      await _apiManager
          .deleteItem(itemId.toString()); // Call the delete API with string
      setState(() {
        items.removeAt(index);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete item: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Furniture Dimensions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Furniture Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildTextField('Name of Furniture', nameController),
                    _buildDimensionField('Length', lengthController),
                    _buildDimensionField('Width', widthController),
                    _buildDimensionField('Height', heightController),
                    SizedBox(height: 10),
                    _buildDropdown('Type of Material', selectedMaterial,
                        ['Glass', 'Wood', 'foam', 'Plastic'], (value) {
                      setState(() {
                        selectedMaterial = value!;
                      });
                    }),
                    _buildDropdown('Type of Fragility', selectedFragility,
                        ['Fragile', 'Non-Fragile'], (value) {
                      setState(() {
                        selectedFragility = value!;
                      });
                    }),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: addItem,
                        child: Text(
                          'Add Item',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (items.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Added Items:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            title: Text(
                                'Name: ${item['name']} | Material: ${item['material']} | Fragility: ${item['fragility']} | Dimensions: ${item['length']} x ${item['width']} x ${item['height']}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                removeItem(index);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (items.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please add at least one item first"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (basketId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Please add an item first to create a basket"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  Navigator.pushNamed(
                    context,
                    Routes.vehicleSelectionRoute,
                    arguments: {
                      'basketId': basketId!,
                      'items': items,
                    },
                  );
                },
                child: Text(
                  'Select the vehicle',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
