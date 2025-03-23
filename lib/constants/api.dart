import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiApiService {
  // Keep your API key here, but be cautious about security in production apps
  static const String apiKey = 'AIzaSyDIgil7Utyc91uRuCk99FxpY1yGka-CcNk';
  static const String apiUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent';

  Future<String> getGeminiResponse(String prompt) async {
    try {
      print(
        'Calling Gemini API with prompt: ${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}...',
      );

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''$prompt
                
                Please provide a comprehensive veterinary report with the following sections:
                1. Potential Diagnosis: Based on the symptoms described
                2. Required Tests: Tests that might be needed to confirm diagnosis
                3. Recommended Medications: Possible treatments and medicines
                4. Care Instructions: Home care recommendations
                5. Precautions: Warning signs to watch for
                6. When to Seek Emergency Care: Critical symptoms requiring immediate veterinary attention
                
                Format your response in a clear, structured way with appropriate sections and bold headings.
                ''',
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      // Log the response status for debugging
      print('Gemini API response status: ${response.statusCode}');
      print('Gemini API response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Updated path to extract text based on the actual API response structure
        if (jsonResponse.containsKey('candidates') &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0].containsKey('content') &&
            jsonResponse['candidates'][0]['content'].containsKey('parts') &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        } else {
          print('Unexpected response structure: $jsonResponse');
          throw Exception('Unexpected response structure from Gemini API');
        }
      } else {
        // Log the error response body for debugging
        print('Gemini API error: ${response.body}');
        throw Exception(
          'Failed to get response from Gemini API: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      // Log detailed error for debugging
      print('Error communicating with Gemini API: $e');
      throw Exception('Error communicating with Gemini API: $e');
    }
  }
}
