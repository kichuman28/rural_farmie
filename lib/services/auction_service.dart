import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auction_item.dart';

class AuctionService {
  final CollectionReference _auctionCollection =
      FirebaseFirestore.instance.collection('auction_items');

  Future<void> addAuctionItem(AuctionItem item) async {
    await _auctionCollection.add({
      'name': item.name,
      'description': item.description,
      'startingBid': item.startingBid,
      'currentBid': item.currentBid,
      'sellerId': item.sellerId,
      'sellerName': item.sellerName,
      'bids': [],
    });
  }

  Stream<List<AuctionItem>> getAuctionItems() {
    return _auctionCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AuctionItem(
          id: doc.id,
          name: doc['name'],
          description: doc['description'],
          startingBid: doc['startingBid'],
          currentBid: doc['currentBid'],
          sellerId: doc['sellerId'],
          sellerName: doc['sellerName'],
          bids: (doc['bids'] as List).map((bid) {
            return Bid(
              bidderId: bid['bidderId'],
              bidderName: bid['bidderName'],
              amount: bid['amount'],
            );
          }).toList(),
        );
      }).toList();
    });
  }

  Future<void> placeBid(String itemId, Bid bid) async {
    await _auctionCollection.doc(itemId).update({
      'currentBid': bid.amount,
      'bids': FieldValue.arrayUnion([{
        'bidderId': bid.bidderId,
        'bidderName': bid.bidderName,
        'amount': bid.amount,
      }]),
    });
  }

  Future<void> closeAuction(String itemId) async {
    await _auctionCollection.doc(itemId).delete();
  }
}
