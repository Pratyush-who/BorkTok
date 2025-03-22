import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class DogProfile {
  final String name;
  final String ownerName;
  final String location;
  final String imageUrl;
  final int age;
  final String breed;

  DogProfile({
    required this.name,
    required this.ownerName,
    required this.location,
    required this.imageUrl,
    required this.age,
    required this.breed,
  });
}

class DogProfilesProvider extends ChangeNotifier {
  // Sample dog profiles
  final List<DogProfile> _allDogProfiles = [
    DogProfile(
      name: 'Max',
      ownerName: 'Sarah Johnson',
      location: 'Seattle, WA',
      imageUrl: 'assets/dog1.jpg',
      age: 3,
      breed: 'Golden Retriever',
    ),
    DogProfile(
      name: 'Bella',
      ownerName: 'David Miller',
      location: 'Portland, OR',
      imageUrl: 'assets/dog2.jpg',
      age: 2,
      breed: 'Labrador',
    ),
    DogProfile(
      name: 'Charlie',
      ownerName: 'Emma Thompson',
      location: 'San Francisco, CA',
      imageUrl: 'assets/dog3.jpg',
      age: 4,
      breed: 'German Shepherd',
    ),
    DogProfile(
      name: 'Luna',
      ownerName: 'Michael Wilson',
      location: 'New York, NY',
      imageUrl: 'assets/dog4.jpeg',
      age: 1,
      breed: 'French Bulldog',
    ),
    DogProfile(
      name: 'Cooper',
      ownerName: 'Jessica Brown',
      location: 'Austin, TX',
      imageUrl: 'assets/dog5.jpg',
      age: 5,
      breed: 'Beagle',
    ),
    DogProfile(
      name: 'Lucy',
      ownerName: 'Robert Davis',
      location: 'Chicago, IL',
      imageUrl: 'assets/dog6.webp',
      age: 3,
      breed: 'Poodle',
    ),
    DogProfile(
      name: 'Bailey',
      ownerName: 'Amanda Wilson',
      location: 'Denver, CO',
      imageUrl: 'assets/dog1.jpg',
      age: 2,
      breed: 'Husky',
    ),
    DogProfile(
      name: 'Rocky',
      ownerName: 'Daniel Martinez',
      location: 'Miami, FL',
      imageUrl: 'assets/dog2.jpg',
      age: 4,
      breed: 'Boxer',
    ),
    DogProfile(
      name: 'Sadie',
      ownerName: 'Jennifer Adams',
      location: 'Boston, MA',
      imageUrl: 'assets/dog3.jpg',
      age: 1,
      breed: 'Dachshund',
    ),
    DogProfile(
      name: 'Tucker',
      ownerName: 'Brian Taylor',
      location: 'Nashville, TN',
      imageUrl: 'assets/dog4.jpeg',
      age: 3,
      breed: 'Australian Shepherd',
    ),
  ];

  List<DogProfile> _dogProfiles = [];

  List<DogProfile> get dogProfiles => _dogProfiles;

  DogProfilesProvider() {
    _resetProfiles();
    print("Initialized with ${_dogProfiles.length} profiles"); // Debug print
  }

  void _resetProfiles() {
    _dogProfiles = List.from(_allDogProfiles);
    notifyListeners();
  }

  void removeTopProfile() {
    if (_dogProfiles.isNotEmpty) {
      _dogProfiles.removeAt(0);
      notifyListeners();
    }
  }

  void refreshProfiles() {
    _resetProfiles();
  }

  bool get isEmpty => _dogProfiles.isEmpty;
}

class TinderScreen extends StatelessWidget {
  const TinderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DogProfilesProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F6),
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/logo.png', width: 40),
              const SizedBox(width: 8),
              Text(
                'BorkTok',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          actions: [],
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: DogTinderCards(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DogTinderCards extends StatefulWidget {
  const DogTinderCards({Key? key}) : super(key: key);

  @override
  State<DogTinderCards> createState() => _DogTinderCardsState();
}

class _DogTinderCardsState extends State<DogTinderCards>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Alignment _dragAlignment = Alignment.center;
  double _dragDistance = 0;

  // New animation properties
  bool _isExiting = false;
  Alignment _exitAlignment = Alignment.center;
  double _exitRotation = 0.0;
  double _exitOpacity = 1.0;
  double _exitScale = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _runResetAnimation() {
    _animationController.reset();
    final animation = Tween(
      begin: _dragAlignment,
      end: Alignment.center,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    animation.addListener(() {
      setState(() {
        _dragAlignment = animation.value;
      });
    });

    _animationController.forward();
  }

  void _handleSwipe(
    BuildContext context,
    DragEndDetails details,
    DogProfilesProvider provider,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_dragDistance.abs() > screenWidth * 0.2) {
      // Direction of swipe
      final isRight = _dragDistance > 0;

      // Start the exit animation
      _playExitAnimation(isRight, provider);
    } else {
      _runResetAnimation();
    }
  }

  void _playExitAnimation(bool isRight, DogProfilesProvider provider) {
    setState(() {
      _isExiting = true;
      _exitAlignment = _dragAlignment;
      _exitRotation = _dragAlignment.x * (math.pi / 8);
    });

    // Calculate final exit position (off-screen)
    final targetX = isRight ? 3.0 : -3.0;
    final targetY = -0.5; // Slightly upward trajectory

    // Animate in stages for a more natural motion
    Future.delayed(const Duration(milliseconds: 10), () {
      if (mounted) {
        setState(() {
          _exitAlignment = Alignment(targetX, targetY);
          _exitRotation =
              (isRight ? 1 : -1) * (math.pi / 4); // More rotation during exit
          _exitScale = 0.8; // Slightly shrink
          _exitOpacity = 0.0; // Fade out
        });
      }
    });

    // Remove the card after animation completes
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        provider.removeTopProfile();
        setState(() {
          _isExiting = false;
          _dragAlignment = Alignment.center;
          _dragDistance = 0;
          _exitOpacity = 1.0;
          _exitRotation = 0.0;
          _exitScale = 1.0;
        });
      }
    });
  }

  void _animateCardSwipe(bool isRight, DogProfilesProvider provider) {
    if (provider.isEmpty) return;

    // Set initial position based on direction
    setState(() {
      _dragAlignment = Alignment(isRight ? 0.5 : -0.5, 0);
      _dragDistance =
          isRight
              ? MediaQuery.of(context).size.width * 0.25
              : -MediaQuery.of(context).size.width * 0.25;
    });

    // Trigger exit animation
    _playExitAnimation(isRight, provider);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DogProfilesProvider>(
      builder: (context, provider, child) {
        print("Building cards with ${provider.dogProfiles.length} profiles");

        if (provider.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No more dogs to show',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    provider.refreshProfiles();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C8D89),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background cards (showing next cards in stack)
                  ...provider.dogProfiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final profile = entry.value;

                    if (index >= 3) return const SizedBox.shrink();

                    // Skip the top card as it will be handled separately
                    if (index == 0) return const SizedBox.shrink();

                    return Positioned(
                      child: Transform.scale(
                        scale: 1.0 - (index * 0.05),
                        child: Transform.translate(
                          offset: Offset(0, index * 10),
                          child: Opacity(
                            opacity: 1.0 - (index * 0.2),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: DogCard(profile: profile),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // Top card (interactive)
                  if (provider.dogProfiles.isNotEmpty)
                    GestureDetector(
                      onPanUpdate: (details) {
                        if (_isExiting)
                          return; // Prevent dragging during animation

                        setState(() {
                          _dragAlignment = Alignment(
                            _dragAlignment.x +
                                details.delta.dx /
                                    (MediaQuery.of(context).size.width / 2),
                            _dragAlignment.y,
                          );
                          _dragDistance =
                              _dragAlignment.x *
                              (MediaQuery.of(context).size.width / 2);
                        });
                      },
                      onPanEnd: (details) {
                        if (_isExiting)
                          return; // Prevent handling swipe during animation
                        _handleSwipe(context, details, provider);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutQuint,
                        transform:
                            Matrix4.identity()
                              ..translate(
                                _isExiting
                                    ? _exitAlignment.x *
                                        (MediaQuery.of(context).size.width / 2)
                                    : _dragAlignment.x *
                                        (MediaQuery.of(context).size.width / 2),
                                _isExiting
                                    ? _exitAlignment.y *
                                        (MediaQuery.of(context).size.height / 2)
                                    : 0.0,
                              )
                              ..rotateZ(
                                _isExiting
                                    ? _exitRotation
                                    : _dragAlignment.x * (math.pi / 8),
                              )
                              ..scale(_isExiting ? _exitScale : 1.0),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _isExiting ? _exitOpacity : 1.0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Stack(
                              children: [
                                DogCard(profile: provider.dogProfiles[0]),
                                // Like indicator
                                if (_dragAlignment.x > 0.15)
                                  Positioned(
                                    top: 20,
                                    left: 20,
                                    child: Transform.rotate(
                                      angle: -0.2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.green,
                                            width: 4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'LIKE',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                // Dislike indicator
                                if (_dragAlignment.x < -0.15)
                                  Positioned(
                                    top: 20,
                                    right: 20,
                                    child: Transform.rotate(
                                      angle: 0.2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.red,
                                            width: 4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'NOPE',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dislike button
                  GestureDetector(
                    onTap: () {
                      if (!provider.isEmpty && !_isExiting) {
                        _animateCardSwipe(false, provider);
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.close, color: Colors.red, size: 32),
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Like button
                  GestureDetector(
                    onTap: () {
                      if (!provider.isEmpty && !_isExiting) {
                        _animateCardSwipe(true, provider);
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class DogCard extends StatelessWidget {
  final DogProfile profile;

  const DogCard({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Force a simple colored background instead of trying to load images
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[100]!, Colors.blue[200]!],
              ),
            ),
            child: Center(
              child: Icon(Icons.pets, size: 100, color: Colors.grey[100]),
            ),
          ),

          // Gradient overlay for better text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.6, 0.8, 1.0],
              ),
            ),
          ),

          // Dog info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${profile.age} ${profile.age == 1 ? 'yr' : 'yrs'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.breed,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Owner: ${profile.ownerName}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.location,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
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
    );
  }
}
