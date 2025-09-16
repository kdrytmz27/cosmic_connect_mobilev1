// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
import 'main_screen.dart';
import 'complete_profile_screen.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // initState'te herhangi bir yönlendirme yapmıyoruz.
    // Bunun yerine, build metodunda AuthProvider'ı dinleyeceğiz.
  }

  // Profilin astrolojik olarak tamamlanıp tamamlanmadığını kontrol eden yardımcı fonksiyon
  bool _isProfileComplete(AuthProvider authProvider) {
    final profile = authProvider.user?.profile;
    // Eğer sun_sign alanı doluysa, profil astrolojik olarak tamamlanmış demektir.
    return profile?.sunSign != null && profile!.sunSign!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider'daki değişiklikleri dinle
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // build metodu her status değişikliğinde tekrar çalışacak.
        // Yönlendirme mantığını yönetmek için WidgetsBinding kullanıyoruz.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          switch (authProvider.status) {
            case AuthStatus.uninitialized:
              // Henüz bir şey yapma, hala token kontrol ediliyor.
              // Ekran zaten bir yükleme göstergesi gösteriyor.
              break;
            case AuthStatus.authenticated:
              // Kullanıcı giriş yapmış. Profili tamamlanmış mı?
              if (_isProfileComplete(authProvider)) {
                // Evet, ana ekrana git.
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              } else {
                // Hayır, profil tamamlama ekranına git.
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => const CompleteProfileScreen()),
                );
              }
              break;
            case AuthStatus.unauthenticated:
              // Kullanıcı giriş yapmamış, giriş ekranına git.
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
              break;
          }
        });

        // AuthProvider durumu ne olursa olsun, SplashScreen her zaman
        // bir yükleme göstergesi gösterir. Yönlendirme arka planda yapılır.
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
