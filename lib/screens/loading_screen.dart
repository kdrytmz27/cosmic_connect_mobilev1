// lib/screens/loading_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Ekran açılır açılmaz polling'i başlat.
    _startPolling();
  }

  void _startPolling() {
    // 3 saniyede bir AuthProvider'a veriyi yenilemesini söyle.
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      print("LoadingScreen: Polling... En güncel veri isteniyor.");
      // listen:false, çünkü değişikliği aşağıdaki Consumer dinliyor.
      context.read<AuthProvider>().refreshUserProfile();
    });
  }

  @override
  void dispose() {
    // Ekrandan çıkıldığında timer'ı mutlaka durdur.
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider'daki değişiklikleri dinlemek için Consumer kullanıyoruz.
    // Bu, en basit ve en güvenilir yöntemdir.
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // AuthProvider'daki kullanıcı verisi güncellendiğinde, bu builder yeniden çalışır.
        // Eğer harita hesaplanmışsa, yönlendirmeyi yap.
        if (authProvider.user?.profile.isBirthChartCalculated == true) {
          // Polling'i durdurup yönlendirmeyi güvenli bir şekilde yap.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _pollingTimer?.cancel();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          });
        }

        // Hesaplama devam ederken gösterilecek olan statik UI.
        return child!;
      },
      // Bu child, Consumer her yeniden tetiklendiğinde tekrar inşa edilmez.
      // Bu, performansı artırır.
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Haritanız oluşturuluyor...',
                  style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
