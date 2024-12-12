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
  final TextEditingController _startingBidController = TextEditingController();

  void _addAuctionItem() {
    final String name = _nameController.text;
    final String description = _descriptionController.text;
    final double startingBid =
        double.tryParse(_startingBidController.text) ?? 0.0;

    if (name.isNotEmpty && description.isNotEmpty && startingBid > 0) {
      final User? user = FirebaseAuth.instance.currentUser; // Get the current user
      final String sellerId = user?.uid ?? 'unknown_user'; // Get user ID
      final String sellerName = user?.displayName ?? 'Unknown'; // Get user name

      final newItem = AuctionItem(
        id: '',
        name: name,
        description: description,
        startingBid: startingBid,
        currentBid: startingBid,
        sellerId: sellerId, // Use the actual user ID
        sellerName: sellerName, // Use the actual user name
        bids: [], // Initialize with an empty list of bids
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
              controller: _startingBidController,
              decoration: InputDecoration(labelText: 'Starting Bid'),
              keyboardType: TextInputType.number,
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
