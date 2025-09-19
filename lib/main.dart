// Lütfen bu kodu kopyalayıp lib/main.dart dosyasının içine yapıştırın.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/complete_profile_screen.dart';
import 'services/api_service.dart';
import 'services/navigation_service.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart'; // Import'un burada olduğundan emin olalım

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CosmicConnectApp());
}

class CosmicConnectApp extends StatelessWidget {
  const CosmicConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- NİHAİ ZAFER DEĞİŞİKLİĞİ ---
    // NotificationProvider, tıpkı AuthProvider gibi global bir state olduğu için,
    // ait olduğu yere, yani uygulamanın en tepesindeki MultiProvider'a geri ekleniyor.
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
        // NotificationProvider buraya geri eklendi!
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
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            switch (authProvider.status) {
              case AuthStatus.uninitialized:
                return const SplashScreen();
              case AuthStatus.unauthenticated:
                return const LoginScreen();
              case AuthStatus.authenticated:
                final userProfile = authProvider.user?.profile;
                if (userProfile != null && userProfile.birthDate != null) {
                  return const MainScreen();
                } else {
                  return const CompleteProfileScreen();
                }
            }
          },
        ),
      ),
    );
  }
}
