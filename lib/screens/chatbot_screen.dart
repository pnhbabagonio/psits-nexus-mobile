import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:psits_nexus_mobile/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  final FocusNode _focusNode = FocusNode();

  // N8N Webhook URL
  static const String _webhookUrl =
      'https://mariaclara1886.app.n8n.cloud/webhook/psits-chatbot';

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _addBotMessage(
      'Hello! I\'m your PSITS Assistant 🤖\n\n'
      'I can help you with information about:\n'
      '• Current PSITS officers and their roles\n'
      '• Upcoming events and activities\n'
      '• Membership requirements and benefits\n'
      '• How to join PSITS\n'
      '• And much more!\n\n'
      'How can I help you today?',
    );
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: false, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _addUserMessage(message);
    _textController.clear();

    setState(() => _isLoading = true);

    try {
      print('🔵 Sending to: $_webhookUrl');
      print('📤 Message: $message');

      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        String? botResponse = await _extractBotResponse(response);

        if (botResponse != null && botResponse.isNotEmpty) {
          _addBotMessage(botResponse);
        } else {
          _addBotMessage(
            'I apologize, but I couldn\'t find a valid response in the data.',
          );
        }
      } else {
        _addBotMessage(
          'I\'m having trouble connecting right now (Status: ${response.statusCode}). '
          'Please try again in a moment or contact the PSITS office directly.',
        );
      }
    } catch (e) {
      print('❌ Exception: $e');
      _addBotMessage(
        'Oops! Something went wrong. Please check your internet connection and try again.\n\n'
        'Error: ${e.toString()}',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _extractBotResponse(http.Response response) async {
    try {
      // First, try to parse as JSON
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        // If JSON parsing fails, try as plain text
        print('⚠️ Response is not JSON, trying as plain text');
        final text = response.body.trim();
        return text.isNotEmpty ? text : null;
      }

      // Check if data is a string
      if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }

      // Check if data is an object
      if (data is Map<String, dynamic>) {
        // Prefer common fields (same as Vue.js logic)
        final candidates = [
          data['response'],
          data['text'],
          data['message'],
          data['output'],
          data['answer'],
        ];

        for (var candidate in candidates) {
          if (candidate is String && candidate.trim().isNotEmpty) {
            print('✅ Found response in candidate field: $candidate');
            return candidate.trim();
          }
        }

        // If nothing from common fields, search object values for first non-empty string
        // (Same as Vue.js Object.values() search)
        final allValues = _extractAllStringValues(data);
        if (allValues.isNotEmpty) {
          print('✅ Found response in extracted values: ${allValues.first}');
          return allValues.first;
        }
      }

      return null;
    } catch (e) {
      print('❌ Error extracting bot response: $e');
      return null;
    }
  }

  // Helper function to deeply extract all string values from a JSON object
  List<String> _extractAllStringValues(dynamic data) {
    final List<String> results = [];

    void extract(dynamic item) {
      if (item is String && item.trim().isNotEmpty) {
        final trimmed = item.trim();
        // Skip empty objects/arrays like Vue.js does
        if (trimmed != '{}' && trimmed != '[]') {
          results.add(trimmed);
        }
      } else if (item is Map) {
        item.values.forEach(extract);
      } else if (item is List) {
        item.forEach(extract);
      } else if (item != null) {
        // For other non-null types, convert to string like Vue.js does
        final str = item.toString();
        final trimmed = str.trim();
        if (trimmed.isNotEmpty && trimmed != '{}' && trimmed != '[]') {
          results.add(trimmed);
        }
      }
    }

    extract(data);
    return results;
  }

  void _handleSubmitted(String text) {
    _sendMessage(text);
  }

  void _showQuickQuestions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Questions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickQuestionChip(
                          'Who are the current officers?',
                        ),
                        _buildQuickQuestionChip(
                          'What are the upcoming events?',
                        ),
                        _buildQuickQuestionChip('How do I join PSITS?'),
                        _buildQuickQuestionChip(
                          'What are the membership benefits?',
                        ),
                        _buildQuickQuestionChip('Where is the PSITS office?'),
                        _buildQuickQuestionChip(
                          'How much is the membership fee?',
                        ),
                        _buildQuickQuestionChip('Can non-members join events?'),
                        _buildQuickQuestionChip('How to contact the officers?'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickQuestionChip(String question) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _sendMessage(question);
      },
      child: Chip(
        label: Text(question),
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        labelStyle: TextStyle(color: AppTheme.primaryColor, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, size: 20),
            SizedBox(width: 8),
            Text('PSITS Assistant'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.question_answer_outlined),
            onPressed: _showQuickQuestions,
            tooltip: 'Quick Questions',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _addBotMessage(
                  'Hello! I\'m your PSITS Assistant 🤖\n\n'
                  'How can I help you today?',
                );
              });
            },
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: SafeArea(
        bottom: false, // We'll handle bottom padding manually
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.smart_toy,
                            size: 64,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'PSITS Assistant',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ask me anything about PSITS',
                            style: TextStyle(
                              color: AppTheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _showQuickQuestions,
                            icon: const Icon(Icons.help_outline),
                            label: const Text('Try Quick Questions'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessage(_messages[index]);
                      },
                    ),
            ),
            if (_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                color: Colors.grey[50],
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'PSITS Assistant is typing...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            // Input container with proper bottom padding
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              // Add padding for keyboard and safe area
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8,
                bottom:
                    8 + bottomSafeArea, // Add safe area padding at the bottom
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14, // Increased vertical padding
                          ),
                        ),
                        onSubmitted: _handleSubmitted,
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_textController.text.trim().isNotEmpty) {
                                _handleSubmitted(_textController.text.trim());
                              }
                            },
                      icon: const Icon(Icons.send, color: Colors.white),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 8, top: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(
                  Icons.smart_toy,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppTheme.primaryColor
                        : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: message.isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: message.isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('hh:mm a').format(message.timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (message.isUser)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
