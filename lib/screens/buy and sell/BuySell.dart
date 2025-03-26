import 'package:borktok/screens/buy%20and%20sell/sellyourdog.dart';
import 'package:flutter/material.dart';
import 'package:borktok/screens/buy and sell/doglistingmodel.dart';
import 'package:borktok/screens/buy and sell/doglistingservice.dart';

class BuySell extends StatefulWidget {
  const BuySell({Key? key}) : super(key: key);

  @override
  _BuySellState createState() => _BuySellState();
}

class _BuySellState extends State<BuySell> {
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
      appBar: AppBar(
        title: const Text('Dog Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellDogScreen(),
                ),
              ).then((_) => _fetchDogListings()); // Refresh listings after returning
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dogListings.isEmpty
              ? const Center(child: Text('No dog listings available'))
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
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dog Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              dogListing.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 50),
                );
              },
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
                    Icon(Icons.location_on, color: Theme.of(context).primaryColor),
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

