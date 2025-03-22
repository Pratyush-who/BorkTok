import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/main_screen.dart';
import '../screens/home_screen.dart';
import '../screens/reels_screen.dart';
import '../screens/tinder_screen.dart';
import '../screens/guide_screen.dart';
import '../screens/essentials_screen.dart';
import '../screens/store_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String main = '/main';
  static const String home = '/home';
  static const String reels = '/reels';
  static const String tinder = '/tinder';
  static const String guide = '/guide';
  static const String essentials = '/essentials';
  static const String store = '/store';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case home:
        // When navigating to home, prevent going back to previous screens
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          settings: RouteSettings(name: settings.name, arguments: settings.arguments),
        );
      case reels:
        return MaterialPageRoute(builder: (context) => const ReelsScreen());
      case tinder:
      return MaterialPageRoute(builder: (context) => const TinderScreen());

      case guide:
        return MaterialPageRoute(builder: (context) => const GuideScreen());
      case essentials:
        return MaterialPageRoute(builder: (context) => const EssentialsScreen());
      case store:
        return MaterialPageRoute(builder: (context) => const StoreScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(), // Default to HomeScreen instead of error page
        );
    }
  }
}