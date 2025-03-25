import 'package:borktok/screens/login_screen.dart';
import 'package:borktok/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/routes.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the snapshot has data (user is logged in)
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          
          if (user == null) {
            // No user is signed in, redirect to login
            return const LoginScreen();
          }
          
          // User is signed in, go to main screen
          return const MainScreen();
        }
        
        // Waiting for connection, show loading screen
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}