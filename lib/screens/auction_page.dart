import 'package:flutter/material.dart';
import '../models/auction_item.dart';
import '../services/auction_service.dart';
import 'add_product_page.dart';
import 'bid_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auction_detail_page.dart';

class AuctionPage extends StatelessWidget {
  final AuctionService _auctionService = AuctionService();

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Auction'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Available Auctions'),
              Tab(text: 'My Auctions'),
            ],
          ),
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
        body: TabBarView(
          children: [
            // Available Auctions Section
            StreamBuilder<List<AuctionItem>>(
              stream: _auctionService.getAuctionItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final auctionItems = snapshot.data ?? [];
                final availableItems = auctionItems
                    .where((item) => item.sellerId != currentUser?.uid)
                    .toList();

                if (availableItems.isEmpty) {
                  return Center(child: Text('No available auctions right now.'));
                }

                return ListView.builder(
                  itemCount: availableItems.length,
                  itemBuilder: (context, index) {
                    final item = availableItems[index];
                    final remainingTime = item.endTime.difference(DateTime.now());
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Bid: \$${item.currentBid}'),
                            Text('Seller: ${item.sellerName}'),
                            Text('Time Remaining: ${remainingTime.inHours}h ${remainingTime.inMinutes.remainder(60)}m'),
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
                      ),
                    );
                  },
                );
              },
            ),

            // My Auctions Section
            StreamBuilder<List<AuctionItem>>(
              stream: _auctionService.getAuctionItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final auctionItems = snapshot.data ?? [];
                final myItems = auctionItems
                    .where((item) => item.sellerId == currentUser?.uid)
                    .toList();

                if (myItems.isEmpty) {
                  return Center(child: Text('You have no active auctions.'));
                }

                // Separate auctions by status
                final liveItems = myItems.where((item) => item.status == AuctionStatus.live).toList();
                final closedItems = myItems.where((item) => item.status == AuctionStatus.closed).toList();
                final upcomingItems = myItems.where((item) => item.status == AuctionStatus.upcoming).toList();
                final expiredItems = myItems.where((item) => item.endTime.isBefore(DateTime.now())).toList();

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      if (liveItems.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Live Auctions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: liveItems.length,
                          itemBuilder: (context, index) {
                            final item = liveItems[index];
                            final remainingTime = item.endTime.difference(DateTime.now());
                            return Card(
                              margin: EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(item.name),
                                subtitle: Text('Current Bid: \$${item.currentBid}\nTime Remaining: ${remainingTime.inHours}h ${remainingTime.inMinutes.remainder(60)}m'),
                                trailing: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    _auctionService.closeAuction(item.id);
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuctionDetailPage(item: item),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                      if (upcomingItems.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Upcoming Auctions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: upcomingItems.length,
                          itemBuilder: (context, index) {
                            final item = upcomingItems[index];
                            return Card(
                              margin: EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(item.name),
                                subtitle: Text('Starting Bid: \$${item.startingBid}'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuctionDetailPage(item: item),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                      if (expiredItems.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Expired Auctions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: expiredItems.length,
                          itemBuilder: (context, index) {
                            final item = expiredItems[index];
                            return Card(
                              margin: EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(item.name),
                                subtitle: Text('Final Bid: \$${item.currentBid}'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuctionDetailPage(item: item),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                      if (closedItems.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Closed Auctions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: closedItems.length,
                          itemBuilder: (context, index) {
                            final item = closedItems[index];
                            return Card(
                              margin: EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(item.name),
                                subtitle: Text('Final Bid: \$${item.currentBid}'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuctionDetailPage(item: item),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
