// lib/providers/unread_provider.dart - SAYAÇ İÇİN GÜNCELLENMİŞ HALİ

import 'package:flutter/foundation.dart';

class UnreadProvider with ChangeNotifier {
  // GÜNCELLEME: Artık boolean yerine integer bir sayaç tutuyoruz.
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // GÜNCELLEME: Sayacı bir artırmak için yeni bir metot.
  void increment() {
    _unreadCount++;
    notifyListeners(); // Dinleyen widget'lara haber ver.
  }

  // GÜNCELLEME: Sayacı sıfırlamak için yeni bir metot.
  void clear() {
    if (_unreadCount == 0) return;
    _unreadCount = 0;
    notifyListeners();
  }
}
