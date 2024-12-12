import 'package:flutter/material.dart';
import '../models/auction_item.dart';
import '../services/auction_service.dart';
import 'add_product_page.dart';
import 'bid_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuctionPage extends StatelessWidget {
  final AuctionService _auctionService = AuctionService();

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Auction'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<AuctionItem>>(
        stream: _auctionService.getAuctionItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final auctionItems = snapshot.data ?? [];

          if (auctionItems.isEmpty) {
            return Center(child: Text('No auctions available right now.'));
          }

          return ListView.builder(
            itemCount: auctionItems.length,
            itemBuilder: (context, index) {
              final item = auctionItems[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Current Bid: \$${item.currentBid}'),
                      Text('Seller: ${item.sellerName}'),
                      if (item.bids.isNotEmpty) 
                        Text('Active Bids:'),
                      ...item.bids.map((bid) => 
                        Text('${bid.bidderName} bid: \$${bid.amount}')
                      ).toList(),
                      if (item.bids.isEmpty) 
                        Text('No active bids available.'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BidPage(item: item),
                      ),
                    );
                  },
                  trailing: item.sellerId == currentUser?.uid
                      ? IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            _auctionService.closeAuction(item.id);
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
} 