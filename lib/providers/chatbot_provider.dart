import 'package:flutter/foundation.dart';

class ChatbotProvider with ChangeNotifier {
  bool _isChatbotOpen = false;
  int _unreadMessages = 0;

  bool get isChatbotOpen => _isChatbotOpen;
  int get unreadMessages => _unreadMessages;

  void openChatbot() {
    _isChatbotOpen = true;
    _unreadMessages = 0;
    notifyListeners();
  }

  void closeChatbot() {
    _isChatbotOpen = false;
    notifyListeners();
  }

  void addUnreadMessage() {
    if (!_isChatbotOpen) {
      _unreadMessages++;
      notifyListeners();
    }
  }

  void resetUnreadMessages() {
    _unreadMessages = 0;
    notifyListeners();
  }
}