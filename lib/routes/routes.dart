import 'package:borktok/screens/reports_Screen.dart';
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/main_screen.dart';
import '../screens/home_screen.dart';
import '../screens/reels_screen.dart';
import '../screens/tinder_screen.dart';
import '../screens/BuySell.dart';
import '../screens/Community.dart';
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
  static const String report = '/report';

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
        return MaterialPageRoute(builder: (context) => const BuySell());
      case essentials:
        return MaterialPageRoute(builder: (context) => const Community());
      case store:
        return MaterialPageRoute(builder: (context) => const StoreScreen());
      case report:
        return MaterialPageRoute(builder: (context) => const ReportsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(), // Default to HomeScreen instead of error page
        );
    }
  }
}