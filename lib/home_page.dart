import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            user?.photoURL != null 
              ? CircleAvatar(
                  backgroundImage: NetworkImage(user!.photoURL!),
                  radius: 50,
                )
              : Icon(Icons.account_circle, size: 100),
            SizedBox(height: 20),
            Text(
              'Welcome, ${user?.displayName ?? "User"}!',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${user?.email ?? "No email"}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class AuctionItem {
  final String id;
  final String name;
  final String description;
  final double startingBid;
  double currentBid;
  final String sellerId;

  AuctionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.startingBid,
    required this.currentBid,
    required this.sellerId,
  });
}