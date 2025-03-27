import 'dart:convert';
import 'package:borktok/screens/buy%20and%20sell/doglistingmodel.dart';
import 'package:borktok/screens/buy%20and%20sell/doglistingservice.dart';
import 'package:borktok/screens/buy%20and%20sell/sellyourdog.dart';
import 'package:flutter/material.dart';

class DogListingsScreen extends StatefulWidget {
  const DogListingsScreen({Key? key}) : super(key: key);

  @override
  _DogListingsScreenState createState() => _DogListingsScreenState();
}

class _DogListingsScreenState extends State<DogListingsScreen> {
  final _dogListingService = DogListingService();
  List<DogListing> _dogListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDogListings();
  }

  Future<void> _fetchDogListings() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final listings = await _dogListingService.getAllDogListings();

      setState(() {
        _dogListings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dog listings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // Warm beige background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5D4A0), // Soft golden background
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo.png', 
            height: 30, 
            width: 30,
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          'Dog Listings',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.brown[800],
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.brown[800]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SellDogScreen()),
              ).then(
                (_) => _fetchDogListings(),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF5D4A0)),
              ),
            )
          : _dogListings.isEmpty
              ? Center(
                  child: Text(
                    'No dog listings available',
                    style: TextStyle(color: Colors.brown[700]),
                  ),
                )
              : ListView.builder(
                  itemCount: _dogListings.length,
                  itemBuilder: (context, index) {
                    final listing = _dogListings[index];
                    return DogListingCard(dogListing: listing);
                  },
                ),
    );
  }
}


class DogListingCard extends StatelessWidget {
  final DogListing dogListing;

  const DogListingCard({Key? key, required this.dogListing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Decode base64 image
    final imageBytes =
        dogListing.imageBase64.isNotEmpty
            ? base64Decode(dogListing.imageBase64)
            : null;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dog Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child:
                imageBytes != null
                    ? Image.memory(imageBytes, fit: BoxFit.cover)
                    : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dog Name and Breed
                Text(
                  '${dogListing.name} - ${dogListing.breed}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),

                // Dog Details
                Row(
                  children: [
                    Icon(Icons.pets, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text('${dogListing.age} years old • ${dogListing.gender}'),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(dogListing.location),
                  ],
                ),
                const SizedBox(height: 8),

                // Price and Description
                Text(
                  '\$${dogListing.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dogListing.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),

                // Owner Info
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Listed by ${dogListing.ownerName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
