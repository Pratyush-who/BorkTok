import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:borktok/constants/api.dart';
import 'package:http/http.dart' as http;

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
    // Initialize asynchronously but don't await
    _initAsync();
  }

  Future<void> _initAsync() async {
  // Test API connection
  _isApiConnected = await testApiConnection();
  
  // Load saved messages
  await _loadMessages();
  
  // Update UI
  if (mounted) {
    setState(() {});
  }
}

Future<bool> testApiConnection() async {
  try {
    final response = await http.get(
      Uri.parse('https://generativelanguage.googleapis.com/v1/models?key=${GeminiApiService.apiKey}'),
    );
    
    print('API test connection status: ${response.statusCode}');
    
    return response.statusCode == 200;
  } catch (e) {
    print('API test connection failed with exception: $e');
    return false;
  }
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
      final String? messagesJson = prefs.getString('dog_chat_messages');
      if (messagesJson != null && messagesJson.isNotEmpty) {
        if (mounted) {
          setState(() {
            try {
              final List<dynamic> jsonList = json.decode(messagesJson);
              _messages = jsonList.map((m) => ChatMessage.fromJson(m)).toList();
            } catch (e) {
              print("Error parsing chat messages: $e");
              _messages = [];
            }
          });
        }
      }
    } catch (e) {
      print("SharedPreferences error: $e");
      // Initialize with empty messages on error
      if (mounted) {
        setState(() {
          _messages = [];
        });
      }
    }
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
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save chat history')),
        );
      }
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

    final userPrompt =
        "I have a ${_breedController.text} dog, ${_ageController.text} years old, with the following symptoms: ${_symptomsController.text}. Please provide a comprehensive report with possible conditions, precautions, medicines, and recommendations.";

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
    // Show typing indicator
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

      // Remove typing indicator
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
      // Remove typing indicator
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
