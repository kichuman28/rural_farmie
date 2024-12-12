class AuctionItem {
  final String id;
  final String name;
  final String description;
  final double startingBid;
  double currentBid;
  final String sellerId;
  final String sellerName;
  final List<Bid> bids;

  AuctionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.startingBid,
    required this.currentBid,
    required this.sellerId,
    required this.sellerName,
    required this.bids,
  });
}

class Bid {
  final String bidderId;
  final String bidderName;
  final double amount;

  Bid({
    required this.bidderId,
    required this.bidderName,
    required this.amount,
  });
} 