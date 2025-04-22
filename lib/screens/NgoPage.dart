import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NgoPage extends StatefulWidget {
  const NgoPage({Key? key}) : super(key: key);

  @override
  State<NgoPage> createState() => _NgoPageState();
}

class _NgoPageState extends State<NgoPage> {
  final List<NgoModel> ngos = [
    NgoModel(
      id: 1,
      name: 'Paws Rescue Center',
      description: 'Shelter and adoption services for stray dogs',
      longDescription:
          'Paws Rescue Center has been operating since 2010 with a mission to provide shelter, medical care, and forever homes for stray and abandoned dogs. We have rescued over 5,000 dogs and successfully rehomed more than 4,200 of them. Our center includes a veterinary clinic, spacious kennels, and a dog training area. We rely heavily on donations and volunteers to continue our mission.',
      icon: Icons.home_outlined,
      address: '123 Rescue Lane, New York, NY 10001',
      phone: '+1 (212) 555-1234',
      email: 'info@pawsrescue.org',
      website: 'www.pawsrescue.org',
      pointsRequired: 200,
      rating: 4.8,
      reviews: 120,
      imageUrl: 'assets/paws_rescue.jpg',
    ),
    NgoModel(
      id: 2,
      name: 'Happy Tails Foundation',
      description: 'Medical treatment for injured street dogs',
      longDescription:
          'Happy Tails Foundation specializes in providing emergency medical care and rehabilitation for injured and sick street dogs. Our team of veterinarians and animal care specialists work around the clock to treat animals in need. We also conduct sterilization campaigns to control the street dog population humanely. Since our founding in 2015, we have treated over 10,000 dogs and conducted more than 7,500 sterilization procedures.',
      icon: Icons.medical_services_outlined,
      address: '456 Healing Ave, Boston, MA 02108',
      phone: '+1 (617) 555-6789',
      email: 'care@happytails.org',
      website: 'www.happytails.org',
      pointsRequired: 150,
      rating: 4.6,
      reviews: 95,
      imageUrl: 'assets/happy_tails.jpg',
    ),
    NgoModel(
      id: 3,
      name: 'Canine Care Coalition',
      description: 'Food and welfare programs for dogs in need',
      longDescription:
          'Canine Care Coalition focuses on providing nutritious food and basic welfare services to street dogs and pets of economically disadvantaged families. We distribute over 5 tons of dog food monthly and provide free vaccinations and parasite control treatments. Our community education programs promote responsible pet ownership and compassion toward animals. We also work with local governments to improve animal welfare policies.',
      icon: Icons.fastfood_outlined,
      address: '789 Welfare Road, San Francisco, CA 94103',
      phone: '+1 (415) 555-4321',
      email: 'help@caninecare.org',
      website: 'www.caninecare.org',
      pointsRequired: 120,
      rating: 4.7,
      reviews: 108,
      imageUrl: 'assets/canine_care.jpg',
    ),
    NgoModel(
      id: 4,
      name: 'Second Chance Dogs',
      description: 'Rehabilitation and rehoming for abused dogs',
      longDescription:
          'Second Chance Dogs specializes in the rehabilitation of abused and traumatized dogs, helping them overcome their fears and behavioral issues through positive reinforcement training and therapy. Our team includes animal behaviorists and trained handlers who provide individualized care plans for each dog. We have a sprawling 5-acre facility with specialized areas for different rehabilitation activities. Since 2012, we have helped over 3,000 dogs find loving homes.',
      icon: Icons.favorite_border,
      address: '321 Hope Street, Seattle, WA 98101',
      phone: '+1 (206) 555-8765',
      email: 'info@secondchancedogs.org',
      website: 'www.secondchancedogs.org',
      pointsRequired: 180,
      rating: 4.9,
      reviews: 132,
      imageUrl: 'assets/second_chance.jpg',
    ),
    NgoModel(
      id: 5,
      name: 'Senior Paws Sanctuary',
      description: 'Care for elderly and special needs dogs',
      longDescription:
          'Senior Paws Sanctuary provides a loving and comfortable environment for elderly dogs and those with special needs that might otherwise be overlooked for adoption. Our facility features heated floors, orthopedic beds, and easy access to outdoor areas. We provide specialized medical care, pain management, and mobility assistance. Many of our residents live out their golden years with us, while others find special adoptive homes with people who understand their unique needs.',
      icon: Icons.elderly,
      address: '567 Golden Years Ave, Denver, CO 80202',
      phone: '+1 (303) 555-2468',
      email: 'care@seniorpaws.org',
      website: 'www.seniorpaws.org',
      pointsRequired: 160,
      rating: 4.7,
      reviews: 89,
      imageUrl: 'assets/senior_paws.jpg',
    ),
  ];

  int userPoints = 600; // Default starting points
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Map to track donations to each NGO
  Map<int, int> ngoDonations = {};

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
    _loadNgoDonations();
  }

  // Load user points from SharedPreferences
  Future<void> _loadUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userPoints = prefs.getInt('userPoints') ?? 600; // Default to 600 if not set
    });
  }

  // Save user points to SharedPreferences
  Future<void> _saveUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userPoints', userPoints);
  }

  // Reset user points to 600
  Future<void> _resetUserPoints() async {
    setState(() {
      userPoints = 600;
    });
    await _saveUserPoints();
    
    // Show a brief feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Points reset to 600'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Add haptic feedback
    HapticFeedback.mediumImpact();
  }

  // Load NGO donations from SharedPreferences
  Future<void> _loadNgoDonations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var ngo in ngos) {
        int donationAmount = prefs.getInt('ngoDonation_${ngo.id}') ?? 0;
        ngoDonations[ngo.id] = donationAmount;
      }
    });
  }

  // Save NGO donation to SharedPreferences
  Future<void> _saveNgoDonation(int ngoId, int donationAmount) async {
    final prefs = await SharedPreferences.getInstance();
    int currentDonation = prefs.getInt('ngoDonation_${ngoId}') ?? 0;
    int newDonation = currentDonation + donationAmount;
    await prefs.setInt('ngoDonation_${ngoId}', newDonation);
    
    setState(() {
      ngoDonations[ngoId] = newDonation;
    });
  }

  // Get remaining points required for an NGO after previous donations
  int getRemainingPoints(NgoModel ngo) {
    int donatedAmount = ngoDonations[ngo.id] ?? 0;
    int calculatedPointsRequired = ngo.pointsRequired;
    
    // Reduce points required based on previous donations
    // For example, reduce by 10% of donated amount (adjust formula as needed)
    if (donatedAmount > 0) {
      int reduction = (donatedAmount * 0.1).round();
      calculatedPointsRequired = (ngo.pointsRequired - reduction).clamp(50, ngo.pointsRequired);
    }
    
    return calculatedPointsRequired;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: Theme.of(context).primaryColor,
              pinned: true,
              title: Row(
                children: [
                  Icon(Icons.volunteer_activism, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Dog NGOs',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                // Points display with double-tap reset functionality
                GestureDetector(
                  onDoubleTap: _resetUserPoints, // Reset points on double tap
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    margin: EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                        SizedBox(width: 5),
                        Text(
                          '$userPoints points',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Search and Filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search NGOs...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildHelpRequestCard(),
                  ],
                ),
              ),
            ),

            // NGO List Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supporting Organizations',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Select an NGO to learn more or donate points',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // NGO List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final ngo = ngos[index];
                  return _buildNgoCard(ngo);
                },
                childCount: ngos.length,
              ),
            ),

            // Extra space at bottom
            SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpRequestCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pets,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                'Request Help for a Dog',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Your Location',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Describe the situation',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 64),
                child: Icon(Icons.description_outlined),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              hintText: 'Is the dog injured? Abandoned? Needs adoption?',
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Implement request submission
                _showRequestSentDialog();
                _locationController.clear();
                _descriptionController.clear();
                
                // Reward user with points for reporting
                setState(() {
                  userPoints += 50;
                  _saveUserPoints();
                });
              },
              icon: Icon(Icons.send),
              label: Text('Send Request to Nearby NGOs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNgoCard(NgoModel ngo) {
    int pointsRequired = getRemainingPoints(ngo);
    int totalDonated = ngoDonations[ngo.id] ?? 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          _showNgoDetailsBottomSheet(ngo);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    ngo.icon,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ngo.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        ngo.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${ngo.rating} (${ngo.reviews})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(width: 16),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.monetization_on,
                                  color: Theme.of(context).primaryColor,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '$pointsRequired points',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (totalDonated > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'You donated: $totalDonated points',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (userPoints >= pointsRequired) {
                          _showDonationDialog(ngo);
                        } else {
                          _showInsufficientPointsDialog();
                        }
                      },
                      icon: Icon(
                        Icons.volunteer_activism,
                        color: Theme.of(context).primaryColor,
                      ),
                      tooltip: 'Donate Points',
                    ),
                    Text(
                      'Donate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNgoDetailsBottomSheet(NgoModel ngo) {
    int pointsRequired = getRemainingPoints(ngo);
    int totalDonated = ngoDonations[ngo.id] ?? 0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView(
              controller: controller,
              padding: EdgeInsets.zero,
              children: [
                // Drag handle
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                
                // Header section with NGO name
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          ngo.icon,
                          color: Theme.of(context).primaryColor,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ngo.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${ngo.rating} (${ngo.reviews} reviews)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Points and donations information
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Donation requires $pointsRequired points',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (totalDonated > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.volunteer_activism,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'You have donated $totalDonated points so far',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // About section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        ngo.longDescription,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Contact information
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildContactItem(Icons.location_on, ngo.address),
                      SizedBox(height: 12),
                      _buildContactItem(Icons.phone, ngo.phone),
                      SizedBox(height: 12),
                      _buildContactItem(Icons.email, ngo.email),
                      SizedBox(height: 12),
                      _buildContactItem(Icons.language, ngo.website),
                    ],
                  ),
                ),
                
                // Activity feed
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildActivityItem(
                        'Rescued 5 puppies from a drainage',
                        '2 days ago',
                        Icons.pets,
                      ),
                      _buildActivityItem(
                        'Conducted vaccination drive at local shelter',
                        '1 week ago',
                        Icons.medical_services,
                      ),
                      _buildActivityItem(
                        'Successfully rehomed 3 senior dogs',
                        '2 weeks ago',
                        Icons.home,
                      ),
                    ],
                  ),
                ),
                
                // Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            if (userPoints >= pointsRequired) {
                              _showDonationDialog(ngo);
                            } else {
                              _showInsufficientPointsDialog();
                            }
                          },
                          icon: Icon(Icons.volunteer_activism),
                          label: Text('Donate Points'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // Implement contact functionality
                          },
                          icon: Icon(Icons.message),
                          label: Text('Contact'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Extra space at bottom
                SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ],
    );
  }

    Widget _buildActivityItem(String title, String time, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDonationDialog(NgoModel ngo) {
  int pointsRequired = getRemainingPoints(ngo);
  
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Donate to ${ngo.name}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'This organization requires $pointsRequired points for a donation.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'You currently have $userPoints points available.',
                  style: TextStyle(fontSize: 16),
                ),
                if (ngoDonations[ngo.id]! > 0) ...[
                  SizedBox(height: 12),
                  Text(
                    'You have already donated ${ngoDonations[ngo.id]} points to this NGO.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Deduct points from user
                        setState(() {
                          userPoints -= pointsRequired;
                          _saveUserPoints();
                          
                          // Record donation to this NGO
                          _saveNgoDonation(ngo.id, pointsRequired);
                        });
                        
                        Navigator.pop(context);
                        _showDonationSuccessDialog(ngo);
                      },
                      child: Text('Donate $pointsRequired Points'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  void _showDonationSuccessDialog(NgoModel ngo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Donation Successful!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Thank you for donating to ${ngo.name}!',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      '${getRemainingPoints(ngo)} points donated.',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showInsufficientPointsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Insufficient Points'),
            ],
          ),
          content: Text(
            'You don\'t have enough points to make this donation. '
            'Complete more dog-related activities to earn points!',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showRequestSentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Request Sent!'),
            ],
          ),
          content: Text(
            'Your request has been sent to nearby NGOs. '
            'You earned 50 points for reporting!',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class NgoModel {
  final int id;
  final String name;
  final String description;
  final String longDescription;
  final IconData icon;
  final String address;
  final String phone;
  final String email;
  final String website;
  final int pointsRequired;
  final double rating;
  final int reviews;
  final String imageUrl;

  NgoModel({
    required this.id,
    required this.name,
    required this.description,
    required this.longDescription,
    required this.icon,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.pointsRequired,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
  });
}