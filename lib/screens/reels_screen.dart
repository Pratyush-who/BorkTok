import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<Map<String, dynamic>> _reels = [
    {
      'username': 'fluffybuddy',
      'videoUrl': 'https://videos.pexels.com/video-files/4157418/4157418-hd_720_1280_30fps.mp4', 
      'caption': 'Walk with the bunchhh...!!! 🐾🏖️',
      'likes': 2453,
      'comments': 148,
      'isLiked': false,
      'isFollowing': false,
    },
    {
      'username': 'barklover',
      'videoUrl': 'https://www.shutterstock.com/shutterstock/videos/3459375705/preview/stock-footage-the-owner-puts-a-bowl-of-food-on-the-table-and-the-dog-jack-rassell-terrier-starts-to-eat-vertical.webm',
      'caption': 'Lunch tymmm...!!! 🍖🍗',
      'likes': 1879,
      'comments': 93,
      'isLiked': false,
      'isFollowing': true,
    },
    {
      'username': 'puppyplaytime',
      'videoUrl': 'https://videos.pexels.com/video-files/2834230/2834230-sd_360_640_15fps.mp4',
      'caption': 'Bro sensed somethingggg....!!!! 🏃‍♂️💨',
      'likes': 3244,
      'comments': 201,
      'isLiked': false,
      'isFollowing': false,
    },
    {
      'username': 'woofpack',
      'videoUrl': 'https://www.shutterstock.com/shutterstock/videos/3486379921/preview/stock-footage-active-funny-crazy-face-dog-running-playing-in-autumn-beautiful-city-perk-happy-smiling-fetching.webm',
      'caption': 'Who wanna playyyy..!!!! 🐕‍🦺🐕🐩',
      'likes': 5670,
      'comments': 312,
      'isLiked': false,
      'isFollowing': false,
    },
    {
      'username': 'goodboy',
      'videoUrl': 'https://videos.pexels.com/video-files/9252757/9252757-sd_360_640_30fps.mp4',
      'caption': 'Let me play tooo... Why only them..!!',
      'likes': 1256,
      'comments': 76,
      'isLiked': false,
      'isFollowing': false,
    },
    {
      'username': 'pawsome',
      'videoUrl': 'https://indianmemetemplates.com/wp-content/uploads/juice-pila-do.mp4',
      'caption': 'OG mitthu don...',
      'likes': 2198,
      'comments': 127,
      'isLiked': false,
      'isFollowing': false,
    },
    {
      'username': 'tailwagger',
      'videoUrl': 'https://www.shutterstock.com/shutterstock/videos/3559732737/preview/stock-footage-adorable-funny-pomeranian-dog-wears-sunglasses-looks-to-the-left-to-the-right-looks-up-then-looks.webm',
      'caption': 'Someones lovin it..!! 🏞️',
      'likes': 3429,
      'comments': 215,
      'isLiked': false,
      'isFollowing': false,
    },
  ];

  // Map to store video controllers
  final Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize the first two videos    _initializeControllers(0);
    _initializeControllers(1);
  }

  void _initializeControllers(int index) {
    if (index >= 0 && index < _reels.length && !_videoControllers.containsKey(index)) {
      final controller = VideoPlayerController.network(_reels[index]['videoUrl']);
      _videoControllers[index] = controller;
      controller.initialize().then((_) {
        if (index == _currentPage) {
          controller.play();
          controller.setLooping(true);
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    // Pause the current video
    if (_videoControllers.containsKey(_currentPage)) {
      _videoControllers[_currentPage]!.pause();
    }
    
    // Play the new current video
    if (_videoControllers.containsKey(page)) {
      _videoControllers[page]!.play();
      _videoControllers[page]!.setLooping(true);
    }
    
    // Initialize next video if needed
    _initializeControllers(page + 1);
    
    setState(() {
      _currentPage = page;
    });
  }

  void _toggleLike(int index) {
    setState(() {
      _reels[index]['isLiked'] = !_reels[index]['isLiked'];
      if (_reels[index]['isLiked']) {
        _reels[index]['likes']++;
      } else {
        _reels[index]['likes']--;
      }
    });
  }

  void _toggleFollow(int index) {
    setState(() {
      _reels[index]['isFollowing'] = !_reels[index]['isFollowing'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Reels PageView for vertical scrolling
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: _reels.length,
            itemBuilder: (context, index) {
              final reel = _reels[index];
              
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Video player
                  _videoControllers.containsKey(index) && _videoControllers[index]!.value.isInitialized
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_videoControllers[index]!.value.isPlaying) {
                                _videoControllers[index]!.pause();
                              } else {
                                _videoControllers[index]!.play();
                              }
                            });
                          },
                          child: VideoPlayer(_videoControllers[index]!),
                        )
                      : const Center(child: CircularProgressIndicator()),
                  
                  // UI Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username and follow button
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[300],
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                reel['username'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _toggleFollow(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(4),
                                    color: reel['isFollowing'] ? Colors.blue : Colors.transparent,
                                  ),
                                  child: Text(
                                    reel['isFollowing'] ? 'Following' : 'Follow',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Caption
                          Text(
                            reel['caption'],
                            style: const TextStyle(color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Side action buttons
                  Positioned(
                    right: 16,
                    bottom: 100,
                    child: Column(
                      children: [
                        // Like button
                        IconButton(
                          onPressed: () => _toggleLike(index),
                          icon: Icon(
                            reel['isLiked'] ? Icons.favorite : Icons.favorite_border,
                            color: reel['isLiked'] ? Colors.red : Colors.white,
                            size: 28,
                          ),
                        ),
                        Text(
                          _formatCount(reel['likes']),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        // Comment button
                        IconButton(
                          onPressed: () {
                            // Show comment sheet
                          },
                          icon: const Icon(Icons.comment, color: Colors.white, size: 28),
                        ),
                        Text(
                          _formatCount(reel['comments']),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        // Share button
                        IconButton(
                          onPressed: () {
                            // Show share options
                          },
                          icon: const Icon(Icons.send, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 16),
                        // Bookmark button
                        IconButton(
                          onPressed: () {
                            // Save video
                          },
                          icon: const Icon(Icons.bookmark_border, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Top navigation bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bark Reels',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Camera functionality
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}