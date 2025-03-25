import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiApiService {
  static String get apiKey => dotenv.get('GEMINI_API_KEY');
  static const String apiUrl = 
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<String> getGeminiResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': 'Generate a concise veterinary report. Structure your response with clear headings: '
                      'Condition, Key Symptoms, Diagnostic Recommendations, Treatment Options, '
                      'Home Care, and Precautions. Provide practical, actionable advice. '
                      'Context for report: $prompt'
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          }
        }),
      );

      // Debug print full response for troubleshooting
      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);

      // Robust error checking for response structure
      if (jsonResponse == null || 
          !jsonResponse.containsKey('candidates') || 
          jsonResponse['candidates'] == null ||
          jsonResponse['candidates'].isEmpty) {
        throw Exception('Invalid API response structure');
      }

      final responseText = _extractResponseText(jsonResponse);
      return _formatReport(responseText);
      
    } catch (e) {
      debugPrint('Comprehensive API Error: $e');
      return _generateFallbackReport(prompt, e);
    }
  }

  String _extractResponseText(Map<String, dynamic> jsonResponse) {
    try {
      return jsonResponse['candidates'][0]['content']['parts'][0]['text'] 
             ?? 'No detailed response received';
    } catch (e) {
      debugPrint('Response text extraction error: $e');
      return 'Unable to process veterinary insights';
    }
  }

  String _generateFallbackReport(String prompt, Object error) {
    return '''🚨 VETERINARY REPORT - EMERGENCY GUIDANCE 🚨

🔹 Connection Issue 🔹
Unfortunately, our automated veterinary assistant encountered a technical difficulty while processing your report.

⚠️ Immediate Recommendations:
1. Check your internet connection
2. Verify API configuration
3. Retry generating the report

📋 Initial Assessment Based on Provided Information:
Symptoms Noted: $prompt

🩺 General Advice:
- Monitor your dog's condition closely
- Consult a veterinarian in person if symptoms persist
- Do not delay professional medical consultation

❗ Technical Error Details:
${error.toString()}

📅 Guidance Generated: ${DateTime.now().toLocal()}
''';
  }

  String _formatReport(String rawReport) {
    return '''🐾 VETERINARY HEALTH REPORT 🐾

$rawReport

📅 Report Generated: ${DateTime.now().toLocal()}
''';
  }
}