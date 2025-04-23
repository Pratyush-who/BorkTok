import 'package:borktok/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes/routes.dart';
void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.deviceCheck,
    );
    await dotenv.load(fileName: ".env");
    print('Loaded environment variables:');
    dotenv.env.forEach((key, value) {
      print('$key: $value');
    });

    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } catch (e) {
    print("Critical Error initializing app: $e");
    
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BorkTok',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF5C8D89),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFF9A03F),
          background: const Color(0xFFFAF8F6),
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A2A2A),
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A2A2A),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF2A2A2A)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF2A2A2A)),
        ),
      ),
      initialRoute: Routes.authWrapper,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}