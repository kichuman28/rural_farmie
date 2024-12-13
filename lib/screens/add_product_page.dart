import 'package:flutter/material.dart';
import '../models/auction_item.dart';
import '../services/auction_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final AuctionService _auctionService = AuctionService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _startingBidController = TextEditingController();
  final TextEditingController _otherCategoryController =
      TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _selectedCategory = 'Vegetables'; // Default category
  Duration _auctionDuration = Duration(hours: 12); // Default auction duration

  List<String> categories = [
    'Vegetables',
    'Fruits',
    'Rice',
    'Grains',
    'Dairy',
    'Others',
  ];

  void _addAuctionItem() {
    final String name = _nameController.text;
    final String description = _descriptionController.text;
    final String location = _locationController.text;
    final int quantity = int.tryParse(_quantityController.text) ?? 0;
    final double startingBid =
        double.tryParse(_startingBidController.text) ?? 0.0;
    final String otherCategoryDescription =
        _selectedCategory == 'Others' ? _otherCategoryController.text : '';

    final int durationHours = int.tryParse(_durationController.text) ?? 12;
    _auctionDuration = Duration(hours: durationHours);

    if (name.isNotEmpty &&
        description.isNotEmpty &&
        location.isNotEmpty &&
        quantity > 0 &&
        startingBid > 0) {
      final User? user =
          FirebaseAuth.instance.currentUser; // Get the current user
      final String sellerId = user?.uid ?? 'unknown_user'; // Get user ID
      final String sellerName = user?.displayName ?? 'Unknown'; // Get user name

      final newItem = AuctionItem(
        id: '',
        name: name,
        description: description,
        location: location,
        quantity: quantity,
        category: _selectedCategory,
        otherCategoryDescription: otherCategoryDescription,
        startingBid: startingBid,
        currentBid: startingBid,
        sellerId: sellerId,
        sellerName: sellerName,
        bids: [],
        endTime: DateTime.now().add(_auctionDuration), // Set auction end time
        status: AuctionStatus.upcoming, // Added required status parameter
      );

      _auctionService.addAuctionItem(newItem);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Auction Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _startingBidController,
              decoration: InputDecoration(labelText: 'Starting Bid'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _durationController,
              decoration: InputDecoration(
                  labelText: 'Auction Duration (hours, default 12)'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (_selectedCategory == 'Others')
              TextField(
                controller: _otherCategoryController,
                decoration:
                    InputDecoration(labelText: 'Describe Other Category'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addAuctionItem,
              child: Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
