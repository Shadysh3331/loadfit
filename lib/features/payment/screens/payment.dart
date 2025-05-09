import 'package:flutter/material.dart';
import 'package:loadfit/core/utils/components/custom_elevated_button.dart';
import 'package:loadfit/core/utils/styles_manager.dart';

class PaymentScreen extends StatelessWidget {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardholderNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
              Text(
                'Card Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),

              Row(
                children: [
                  // Expiry Date Field
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expiry Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _expiryDateController,
                          decoration: InputDecoration(
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CVV',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _cvvController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Text(
                'Cardholder Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _cardholderNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Center(
                child: CustomElevatedButton(
                  backgroundColor: Colors.blueAccent,
                  label: "Pay Now",
                  onTap: () {
                    // Handle payment logic here
                    _processPayment(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processPayment(BuildContext context) {
    // Validate and process payment
    final cardNumber = _cardNumberController.text;
    final expiryDate = _expiryDateController.text;
    final cvv = _cvvController.text;
    final cardholderName = _cardholderNameController.text;

    if (cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty || cardholderName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Simulate payment processing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the next screen or perform other actions
      Navigator.pop(context); // Go back to the previous screen
    }
  }
}