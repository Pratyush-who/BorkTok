import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:borktok/constants/api.dart';
import 'package:http/http.dart' as http;

// Modified extension without hardcoded breeds list
extension StringValidation on String {
  bool isValidDogBreed() {
    // Instead of validating against a hardcoded list,
    // just perform basic validation to ensure the input is reasonable
    final trimmed = trim();
    return trimmed.isNotEmpty && trimmed.length >= 2;
  }

  bool isValidDogAge() {
    try {
      final age = double.parse(this);
      return age > 0 && age < 25; // Reasonable dog age range
    } catch (e) {
      return false;
    }
  }
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'User');
  final ChatUser _geminiBot = ChatUser(id: '2', firstName: 'VetBot');
  List<ChatMessage> _messages = [];
  final GeminiApiService _apiService = GeminiApiService();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  bool _showForm = true;
  bool _isApiConnected = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    _isApiConnected = await testApiConnection();
    await _loadMessages();

    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> testApiConnection() async {
    try {
      final apiKey = GeminiApiService.apiKey;
      final apiUrl = GeminiApiService.apiUrl;

      if (apiKey.isEmpty) {
        throw Exception('API key not configured');
      }

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Connection test'},
              ],
            },
          ],
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API Connection Test Failed: $e');
      return false;
    }
  }

  void _handleSubmitForm() {
    if (_breedController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _symptomsController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (!_isApiConnected) {
      _showApiErrorSnackbar(
        "Cannot generate report: API connection failed. Please check your internet connection and try again.",
      );
      return;
    }

    final userPrompt = _constructDetailedPrompt();

    final message = ChatMessage(
      user: _currentUser,
      createdAt: DateTime.now(),
      text: userPrompt,
    );

    setState(() {
      _messages.insert(0, message);
      _showForm = false;
    });

    _getGeminiResponse(userPrompt);
    _saveMessages();
  }

  String _constructDetailedPrompt() {
    final breed = _breedController.text.trim();
    final age = _ageController.text.trim();
    final symptoms = _symptomsController.text.trim();

    // Breed validation
    if (!breed.isValidDogBreed()) {
      return '''❌ Breed Validation Error

The breed name provided is too short or empty. Please enter a valid dog breed name.

Your dog's breed helps us provide breed-specific health information. Please enter a valid breed name.''';
    }

    // Age validation
    if (!age.isValidDogAge()) {
      return '''❌ Age Validation Error

The age "$age" is not valid. 

Please enter a realistic dog age:
• Puppies: 0-2 years
• Adult dogs: 2-10 years
• Senior dogs: 10-15 years

Your entered age should be a number between 0 and 25.''';
    }

    // Symptoms validation (simple check to ensure not empty)
    if (symptoms.isEmpty || symptoms.length < 3) {
      return '''❌ Symptoms Validation Error

Please provide more detailed symptoms about your dog's condition.

Examples:
• "Limping, loss of appetite"
• "Coughing, lethargy"
• "Vomiting, drinking excessive water"

Detailed symptoms help in generating an accurate health report.''';
    }

    // Concise report template
    return '''Veterinary Health Assessment

Dog Profile:
• Breed: $breed
• Age: $age years
• Symptoms: $symptoms

Quick Health Report Sections:
1. Potential Conditions
   - Key medical concerns
   - Immediate risk assessment

2. Diagnostic Suggestions
   - Essential tests
   - Urgent vs. routine examinations

3. Treatment Recommendations
   - Primary interventions
   - Home care strategies

4. Preventive Care
   - Breed-specific health tips
   - Age-appropriate wellness advice

**Important**: This report is for informational purposes. Always consult a veterinarian for definitive diagnosis and treatment.''';
  }

  void _showApiErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('dog_chat_messages');

      if (messagesJson != null) {
        final messages = await compute(_parseMessages, messagesJson);
        if (mounted) {
          setState(() => _messages = messages);
        }
      }
    } catch (e) {
      debugPrint("Error loading messages: $e");
    }
  }

  static List<ChatMessage> _parseMessages(String jsonStr) {
    return (json.decode(jsonStr) as List)
        .map((m) => ChatMessage.fromJson(m))
        .toList();
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = json.encode(
        _messages.map((m) => m.toJson()).toList(),
      );
      await prefs.setString('dog_chat_messages', messagesJson);
    } catch (e) {
      print("Error saving messages: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save chat history')),
        );
      }
    }
  }

  void _handleSendPressed(ChatMessage message) {
    if (!_isApiConnected) {
      _showApiErrorSnackbar(
        "Cannot send message: API connection failed. Please check your internet connection and try again.",
      );
      return;
    }

    setState(() {
      _messages.insert(0, message);
    });

    _getGeminiResponse(message.text);
    _saveMessages();
  }

  Future<void> _getGeminiResponse(String prompt) async {
    setState(() {
      _messages.insert(
        0,
        ChatMessage(user: _geminiBot, createdAt: DateTime.now(), text: '...'),
      );
    });

    try {
      print("Calling Gemini API...");
      final response = await _apiService.getGeminiResponse(prompt);
      print("Gemini API response received");

      setState(() {
        _messages.removeAt(0);
      });

      final botMessage = ChatMessage(
        user: _geminiBot,
        createdAt: DateTime.now(),
        text: response,
      );

      setState(() {
        _messages.insert(0, botMessage);
      });
    } catch (e) {
      print("Error getting Gemini response: $e");
      setState(() {
        _messages.removeAt(0);
      });

      final errorMessage = ChatMessage(
        user: _geminiBot,
        createdAt: DateTime.now(),
        text:
            'Sorry, I encountered an error: ${e.toString()}. Please check your internet connection and try again.',
      );

      setState(() {
        _messages.insert(0, errorMessage);
      });
    }

    _saveMessages();
  }

  // New method to parse text with bold formatting
  List<InlineSpan> _parseRichText(String text) {
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final matches = boldRegex.allMatches(text);
    List<InlineSpan> spans = [];
    int lastEnd = 0;

    for (var match in matches) {
      // Add text before the bold section
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      // Add bold section
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text after last match
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Health Assistant- E-VET',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          if (!_isApiConnected)
            Container(
              width: double.infinity,
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'API connection failed. Some features may not work correctly.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (_showForm)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  color: const Color(0xFFF5F5DC), // Beige color
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Dog Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _breedController,
                          decoration: const InputDecoration(
                            labelText: 'Dog Breed',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle: TextStyle(color: Color(0xFF388E3C)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF388E3C)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: 'Age (in years)',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle: TextStyle(color: Color(0xFF388E3C)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF388E3C)),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _symptomsController,
                          decoration: const InputDecoration(
                            labelText: 'Symptoms (comma separated)',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle: TextStyle(color: Color(0xFF388E3C)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF388E3C)),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _handleSubmitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Generate Health Report'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: DashChat(
                currentUser: _currentUser,
                onSend: _handleSendPressed,
                messages: _messages,
                inputOptions: InputOptions(
                  inputDecoration: InputDecoration(
                    hintText: 'Ask more about your dog\'s health...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  sendButtonBuilder: (onPressed) {
                    return GestureDetector(
                      onTap: onPressed,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF388E3C),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
                messageOptions: MessageOptions(
                  containerColor: const Color(0xFFDFF2DF),
                  currentUserContainerColor: const Color(0xFF81C784),
                  showTime: true,
                  messageTextBuilder: (message, previousMessage, nextMessage) {
                    return Text.rich(
                      TextSpan(
                        children: _parseRichText(message.text),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (!_showForm)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showForm = true;
                    _breedController.clear();
                    _ageController.clear();
                    _symptomsController.clear();
                  });
                },
                icon: const Icon(Icons.pets, color: Color(0xFF2E7D32)),
                label: const Text(
                  'New Dog Report',
                  style: TextStyle(color: Color(0xFF2E7D32)),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFE8F5E9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}