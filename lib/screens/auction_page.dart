import 'package:flutter/material.dart';
import '../models/auction_item.dart';
import '../services/auction_service.dart';
import 'add_product_page.dart';
import 'bid_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auction_detail_page.dart';

class AuctionPage extends StatefulWidget {
  @override
  _AuctionPageState createState() => _AuctionPageState();
}

class _AuctionPageState extends State<AuctionPage> with SingleTickerProviderStateMixin {
  final AuctionService _auctionService = AuctionService();
  String _searchQuery = '';
  String? _selectedCategory;
  List<String> categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Rice',
    'Grains',
    'Dairy',
    'Others',
  ];

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
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Auctions',
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedCategory,
                  hint: Text('Select Category'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  items: categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: StreamBuilder<List<AuctionItem>>(
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
                          .where((item) =>
                              _selectedCategory == null ||
                              _selectedCategory == 'All' ||
                              item.category == _selectedCategory)
                          .where((item) => item.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
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
                              trailing: CircularProgressIndicator(
                                value: remainingTime.inSeconds > 0
                                    ? (remainingTime.inSeconds / item.endTime.difference(DateTime.now()).inSeconds)
                                    : 0,
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
                ),
              ],
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

                return ListView.builder(
                  itemCount: myItems.length,
                  itemBuilder: (context, index) {
                    final item = myItems[index];
                    final remainingTime = item.endTime.difference(DateTime.now());
                    return GestureDetector(
                      onLongPress: () async {
                        await Future.delayed(Duration(milliseconds: 300)); // Delay before showing dialog
                        _showCloseAuctionDialog(context, item.id, item.endTime);
                      },
                      child: Card(
                        margin: EdgeInsets.all(8.0),
                        color: remainingTime.isNegative ? Colors.red[100] : Colors.white, // Change color if expired
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            'Current Bid: \$${item.currentBid}\nTime Remaining: ${remainingTime.inHours}h ${remainingTime.inMinutes.remainder(60)}m',
                          ),
                          trailing: _getStatusIndicator(item),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AuctionDetailPage(item: item),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCloseAuctionDialog(BuildContext context, String itemId, DateTime endTime) {
    final remainingTime = endTime.difference(DateTime.now());

    if (remainingTime.isNegative) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Close Auction'),
            content: Text('Are you sure you want to close this auction?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await _auctionService.closeAuction(itemId);
                  Navigator.of(context).pop(); // Close the dialog
                  setState(() {}); // Refresh the UI
                },
                child: Text('Confirm'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Cannot Close Auction'),
            content: Text('You can only close the auction after it has ended.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _getStatusIndicator(AuctionItem item) {
    Color color;
    if (item.endTime.isAfter(DateTime.now())) {
      color = Colors.green; // Active auction
    } else if (item.status == AuctionStatus.closed) {
      color = Colors.red; // Auction completely over
    } else {
      color = Colors.yellow; // Bidding time over but unsold
    }
    return Container(
      width: 10,
      height: 10,
      color: color,
    );
  }
}
