import 'package:flutter/material.dart';
import '../models/auction_item.dart';

class AuctionDetailPage extends StatelessWidget {
  final AuctionItem item;

  AuctionDetailPage({required this.item});

  @override
  Widget build(BuildContext context) {
    final highestBid = item.bids.isNotEmpty
        ? item.bids.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;

    final remainingTime = item.endTime.difference(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${item.description}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Location: ${item.location}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Quantity: ${item.quantity}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Starting Bid: \$${item.startingBid}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Current Bid: \$${item.currentBid}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Time Remaining: ${remainingTime.inHours}h ${remainingTime.inMinutes.remainder(60)}m', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Highest Bidder: ${highestBid != null ? highestBid.bidderName : 'No bids yet'}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Bids:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: item.bids.length,
                itemBuilder: (context, index) {
                  final bid = item.bids[index];
                  return ListTile(
                    title: Text('${bid.bidderName}'),
                    subtitle: Text('Bid Amount: \$${bid.amount}'),
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