import 'package:borktok/screens/buy%20and%20sell/sellyourdog.dart';
import 'package:flutter/material.dart';
import 'package:borktok/screens/buy%20and%20sell/doglistingmodel.dart';
import 'package:borktok/screens/buy%20and%20sell/doglistingservice.dart';

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
      backgroundColor: const Color(0xFFFFF3E0), // Warm beige background
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 239, 238, 236), // Soft golden background
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
            color: const Color.fromARGB(255, 16, 33, 7),
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: const Color.fromARGB(255, 4, 30, 8)),
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
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF5D4A0)),
              ),
            )
          : _dogListings.isEmpty
              ? Center(
                  child: Text(
                    'No dog listings available',
                    style: TextStyle(color: Theme.of(context).primaryColor),
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
    return Card(
      margin: const EdgeInsets.all(8),
      color: Colors.white, // White card background
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dog Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                dogListing.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 50, color: Color.fromARGB(255, 1, 56, 30)),
                  );
                },
              ),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Dog Details
                Row(
                  children: [
                    Icon(Icons.pets, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      '${dogListing.age} years old • ${dogListing.gender}',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
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
                    Text(
                      dogListing.location,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Price and Description
                Text(
                  '\$${dogListing.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dogListing.description,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 8),
                
                // Owner Info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Listed by ${dogListing.ownerName}',
                      style: TextStyle(color: Theme.of(context).primaryColor),
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