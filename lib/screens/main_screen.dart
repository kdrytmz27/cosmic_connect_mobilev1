// Lütfen bu kodu kopyalayıp lib/screens/main_screen.dart dosyasının içine yapıştırın.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import 'discover_screen.dart';
import 'activity_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import '../services/notification_service.dart';
import '../providers/notification_provider.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  final NotificationService _notificationService = NotificationService();

  static const List<Widget> _widgetOptions = <Widget>[
    DiscoverScreen(),
    ActivityScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService.init(context);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- NİHAİ MİMARİ DEĞİŞİKLİĞİ ---
    // MultiProvider ve karmaşık ProxyProvider buradan KALDIRILDI.
    // MainScreen artık sadece bir iskelet görevi görüyor.
    // Her ekran kendi ihtiyacı olan provider'ı kendi içinde yönetecek.
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          // NotificationProvider global kalabilir, sorun değil.
          return BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: 'Keşfet'),
              BottomNavigationBarItem(
                  icon: badges.Badge(
                      showBadge: provider.hasNewActivity,
                      child: const Icon(Icons.notifications_none)),
                  activeIcon: const Icon(Icons.notifications),
                  label: 'Aktivite'),
              BottomNavigationBarItem(
                  icon: badges.Badge(
                      showBadge: provider.hasNewMessage,
                      child: const Icon(Icons.chat_bubble_outline)),
                  activeIcon: const Icon(Icons.chat_bubble),
                  label: 'Mesajlar'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profil'),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.purple,
            unselectedItemColor: Colors.grey[600],
            showUnselectedLabels: true,
          );
        },
      ),
    );
  }
}
