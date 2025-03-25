import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/routes.dart';

void main() async {
  try {
    // Ensure flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load environment variables with error logging
    await dotenv.load(fileName: ".env");
    
    // Print out loaded environment variables for debugging
    print('Loaded environment variables:');
    dotenv.env.forEach((key, value) {
      print('$key: $value');
    });
  } catch (e) {
    print("Critical Error loading .env file: $e");
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
      initialRoute: Routes.splash,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
