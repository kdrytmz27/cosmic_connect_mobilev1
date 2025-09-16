// lib/providers/notification_provider.dart

import 'package:flutter/foundation.dart';

class NotificationProvider with ChangeNotifier {
  bool _hasNewActivity = false;
  bool _hasNewMessage = false;

  bool get hasNewActivity => _hasNewActivity;
  bool get hasNewMessage => _hasNewMessage;

  void setNewActivity(bool value) {
    if (_hasNewActivity != value) {
      _hasNewActivity = value;
      notifyListeners();
    }
  }

  void setNewMessage(bool value) {
    if (_hasNewMessage != value) {
      _hasNewMessage = value;
      notifyListeners();
    }
  }
}
