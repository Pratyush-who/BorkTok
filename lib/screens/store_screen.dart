import 'package:flutter/material.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final List<StoreItem> _storeItems = [
    StoreItem(
      name: 'Premium Dog Collar',
      description: 'Luxurious leather collar for your furry friend',
      points: 500,
      image: 'assets/dog1.jpg',
      category: ItemCategory.accessories,
    ),
    StoreItem(
      name: 'Personalized Dog Bed',
      description: 'Comfortable memory foam bed with your dog\'s name',
      points: 1200,
      image: 'assets/dog2.jpg',
      category: ItemCategory.comfort,
    ),
    StoreItem(
      name: 'Professional Grooming Kit',
      description: 'Complete grooming set for all dog breeds',
      points: 800,
      image: 'assets/dog3.jpg',
      category: ItemCategory.care,
    ),
    StoreItem(
      name: 'Interactive Dog Toy Set',
      description: 'Smart toys to keep your furry friend entertained',
      points: 300,
      image: 'assets/dog4.jpeg',
      category: ItemCategory.toys,
    ),
    StoreItem(
      name: 'Dog Training Masterclass',
      description: 'Online training course by professional trainers',
      points: 1500,
      image: 'assets/dog5.jpg',
      category: ItemCategory.training,
    ),
    StoreItem(
      name: 'Veterinary Consultation',
      description: 'Online vet consultation with expert',
      points: 750,
      image: 'assets/evett.png',
      category: ItemCategory.health,
    ),
    StoreItem(
      name: 'Doggy Travel Carrier',
      description: 'Comfortable and secure carrier for small dogs',
      points: 900,
      image: 'assets/logo.png',
      category: ItemCategory.accessories,
    ),
    StoreItem(
      name: 'Wellness Supplement Pack',
      description: 'Nutritional supplements for optimal dog health',
      points: 650,
      image: 'assets/dog6.webp',
      category: ItemCategory.health,
    ),
  ];
  final List<RedeemHistoryItem> _redeemHistory = [];
  int _userPoints = 5000; 
  ItemCategory? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  List<StoreItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _storeItems;
  }

  void _filterItems(String query, {ItemCategory? category}) {
    setState(() {
      _filteredItems =
          _storeItems.where((item) {
            final matchesQuery =
                query.isEmpty ||
                item.name.toLowerCase().contains(query.toLowerCase());
            final matchesCategory =
                category == null || item.category == category;
            return matchesQuery && matchesCategory;
          }).toList();
    });
  }

  void _redeemItem(StoreItem item) {
    if (_userPoints >= item.points) {
      setState(() {
        _userPoints -= item.points;
        _redeemHistory.add(
          RedeemHistoryItem(item: item, redeemDate: DateTime.now()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 241, 240, 238),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png', width: 40, height: 40),
        ),
        title: Text(
          'BorkTok Store',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            fontSize: 22,
          ),
        ),
        actions: [
          // Redeem History Button
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _showRedeemHistoryDialog(context);
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.pets,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_userPoints Points',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterItems('');
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onChanged: (value) {
                    _filterItems(value, category: _selectedCategory);
                  },
                ),
              ),
              // Category Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children:
                        ItemCategory.values.map((category) {
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(category.name.capitalize()),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedCategory =
                                      selected ? category : null;
                                  _filterItems(
                                    _searchController.text,
                                    category: _selectedCategory,
                                  );
                                });
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75, // Reduced from 0.85
        ),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return _buildStoreItemCard(context, item);
        },
      ),
    );
  }

  Widget _buildStoreItemCard(BuildContext context, StoreItem item) {
  return GestureDetector(
    onTap: () {
      _showItemDetailsBottomSheet(context, item);
    },
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Changed to stretch
        children: [
          // Item Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(15),
            ),
            child: Image.asset(
              item.image,
              height: 130, // Reduced from 120
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Expanded( // Added Expanded to distribute space
            child: Padding(
              padding: const EdgeInsets.all(6), // Reduced from 8
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Added to push points to bottom
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14, // Reduced from 14
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2), // Reduced from 4
                      Text(
                        item.description,
                        style: TextStyle(fontSize: 12, color: Colors.brown[600]), // Reduced from 11
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.pets,
                        color: Theme.of(context).primaryColor,
                        size: 14, // Reduced from 16
                      ),
                      const SizedBox(width: 4), // Reduced from 6
                      Text(
                        '${item.points} Points',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11, // Reduced from 12
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  void _showItemDetailsBottomSheet(BuildContext context, StoreItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5DC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView(
                controller: controller,
                children: [
                  // Item Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.asset(
                      item.image,
                      height: 340,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item Name
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[800],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Points Required
                        Row(
                          children: [
                            Icon(
                              Icons.pets,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.points} Points Required',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Text(
                          'Detailed Description:\n${item.description}\n\nEnjoy a high-quality product that brings joy and comfort to your furry friend. This item is carefully curated to meet the highest standards of pet care and enjoyment.',
                          style: TextStyle(
                            color: Colors.brown[700],
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Redeem Button
                        Center(
                          child: ElevatedButton(
                            onPressed:
                                _userPoints >= item.points
                                    ? () {
                                      // Redeem logic
                                      _redeemItem(item);
                                      Navigator.pop(context);
                                      _showRedemptionSuccessDialog(
                                        context,
                                        item,
                                      );
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              _userPoints >= item.points
                                  ? 'Redeem Now'
                                  : 'Insufficient Points',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRedemptionSuccessDialog(BuildContext context, StoreItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F5DC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Icon(
            Icons.check_circle,
            color: Theme.of(context).primaryColor,
            size: 80,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Redemption Successful!',
                style: TextStyle(
                  color: Colors.brown[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'You have successfully redeemed ${item.name}',
                style: TextStyle(color: Colors.brown[700], fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRedeemHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Redeem History'),
          content:
              _redeemHistory.isEmpty
                  ? const Text('No redemption history yet.')
                  : SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _redeemHistory.length,
                      itemBuilder: (context, index) {
                        final historyItem =
                            _redeemHistory[_redeemHistory.length - 1 - index];
                        return Column(
                          children: [
                            ListTile(
                              title: Text(historyItem.item.name),
                              subtitle: Text(
                                _formatDate(historyItem.redeemDate),
                              ),
                              trailing: Text(
                                '${historyItem.item.points} Points',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            if (index < _redeemHistory.length - 1)
                              const Divider(),
                          ],
                        );
                      },
                    ),
                  ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Enum for item categories
enum ItemCategory { accessories, comfort, care, toys, training, health }

// Extension to capitalize first letter of enum
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class RedeemHistoryItem {
  final StoreItem item;
  final DateTime redeemDate;

  RedeemHistoryItem({required this.item, required this.redeemDate});
}

class StoreItem {
  final String name;
  final String description;
  final int points;
  final String image;
  final ItemCategory category;

  StoreItem({
    required this.name,
    required this.description,
    required this.points,
    required this.image,
    required this.category,
  });
}
