// Lütfen bu kodu kopyalayıp lib/main.dart dosyasının içine yapıştırın.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/complete_profile_screen.dart'; // YENİ: Profil tamamlama ekranını import ettik
import 'services/api_service.dart';
import 'services/navigation_service.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CosmicConnectApp());
}

class CosmicConnectApp extends StatelessWidget {
  const CosmicConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProxyProvider<ApiService, AuthProvider>(
          create: (context) => AuthProvider(context.read<ApiService>()),
          update: (context, apiService, previous) =>
              previous ?? AuthProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Cosmic Connect',
        navigatorKey: NavigationService.navigatorKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('tr', 'TR')],
        locale: const Locale('tr', 'TR'),
        theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            elevation: 1,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        // YÖNLENDİRME MANTIĞI BURADA GÜNCELLENDİ
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            switch (authProvider.status) {
              case AuthStatus.uninitialized:
                // Uygulama ilk açıldığında veya durum belirsizken bekleme ekranı gösterilir.
                return const SplashScreen();

              case AuthStatus.unauthenticated:
                // Kullanıcı giriş yapmamışsa giriş ekranına yönlendirilir.
                return const LoginScreen();

              case AuthStatus.authenticated:
                // Kullanıcı giriş yapmışsa, profilinin tam olup olmadığını kontrol et.
                final userProfile = authProvider.user?.profile;
                if (userProfile != null && userProfile.birthDate != null) {
                  // Profil TAMAMLANMIŞ: Ana ekrana yönlendir.
                  return const MainScreen();
                } else {
                  // Profil EKSİK: Zorunlu profil tamamlama ekranına yönlendir.
                  return const CompleteProfileScreen();
                }
            }
          },
        ),
      ),
    );
  }
}
