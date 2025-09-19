// Lütfen bu kodu kopyalayıp lib/screens/profile_screen.dart dosyasının içine yapıştırın.

import 'dart:convert'; // Base64 çözümlemesi için EKLENDİ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../models/app_user.dart';
import '../services/api_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String getZodiacSignSymbol(String? signName) {
    if (signName == null) return '';
    const Map<String, String> zodiacSymbols = {
      'Koç': '♈',
      'Boğa': '♉',
      'İkizler': '♊',
      'Yengeç': '♋',
      'Aslan': '♌',
      'Başak': '♍',
      'Terazi': '♎',
      'Akrep': '♏',
      'Yay': '♐',
      'Oğlak': '♑',
      'Kova': '♒',
      'Balık': '♓',
    };
    return zodiacSymbols[signName] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return ChangeNotifierProvider(
      create: (ctx) => ProfileProvider(ctx.read<ApiService>()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profilim'),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  );
                } else if (value == 'logout') {
                  context.read<AuthProvider>().logout();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Profili Düzenle'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Çıkış Yap'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: user == null
            ? const Center(child: Text("Kullanıcı bulunamadı."))
            : RefreshIndicator(
                onRefresh: () => authProvider.refreshUserProfile(),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildProfileHeader(context, user),
                    const SizedBox(height: 24),

                    // --- GÖREV 7 DEĞİŞİKLİĞİ: Doğum Haritası Kartı ---
                    // Eğer harita görseli mevcutsa, bu kartı göster.
                    if (user.profile.natalChartPngBase64 != null &&
                        user.profile.natalChartPngBase64!.isNotEmpty)
                      _buildNatalChartCard(
                          context, user.profile.natalChartPngBase64!),

                    const SizedBox(height: 16),
                    _buildSectionCard(
                      context,
                      title: 'Astrolojik DNA',
                      icon: Icons.auto_awesome,
                      children: [
                        _buildAstroInfoRow(
                            'Güneş', user.profile.sunSignDisplay),
                        _buildAstroInfoRow('Ay', user.profile.moonSignDisplay),
                        _buildAstroInfoRow(
                            'Yükselen', user.profile.risingSignDisplay),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      context,
                      title: 'Kişisel Gezegenler',
                      icon: Icons.public,
                      children: [
                        _buildAstroInfoRow(
                            'Merkür', user.profile.mercurySignDisplay),
                        _buildAstroInfoRow(
                            'Venüs', user.profile.venusSignDisplay),
                        _buildAstroInfoRow(
                            'Mars', user.profile.marsSignDisplay),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHoroscopeSection(),
                  ],
                ),
              ),
      ),
    );
  }

  // --- GÖREV 7 DEĞİŞİKLİĞİ: Doğum Haritası Kartını oluşturan yeni widget ---
  Widget _buildNatalChartCard(BuildContext context, String base64Image) {
    // Base64 string'inin başındaki "data:image/png;base64," kısmını temizle
    final cleanBase64 = base64Image.split(',').last;
    final imageBytes = base64Decode(cleanBase64);

    return _buildSectionCard(
      context,
      title: 'Doğum Haritan',
      icon: Icons.brightness_high, // Güneş ikonu haritayı temsil edebilir
      children: [
        GestureDetector(
          onTap: () {
            // Haritaya tıklandığında tam ekran göstermek için bir diyalog aç
            showDialog(
              context: context,
              builder: (ctx) => Dialog(
                child: InteractiveViewer(
                  // Yakınlaştırma ve kaydırma için
                  child: Image.memory(imageBytes),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.memory(
              imageBytes,
              fit: BoxFit.cover,
              // Yüklenirken veya hata durumunda gösterilecek widget'lar
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text("Harita yüklenemedi."));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppUser user) {
    // ... Bu widget'ta değişiklik yok ...
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: user.profile.avatar != null
              ? NetworkImage(user.profile.avatar!)
              : null,
          child: user.profile.avatar == null
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          '${user.username}, ${user.profile.age ?? ''}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          user.profile.bio.isNotEmpty
              ? user.profile.bio
              : 'Hakkında henüz bir şey yazmamış.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    // ... Bu widget'ta değişiklik yok ...
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAstroInfoRow(String label, String? value) {
    // ... Bu widget'ta değişiklik yok ...
    final symbol = getZodiacSignSymbol(value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Row(
            children: [
              if (symbol.isNotEmpty)
                Text(
                  '$symbol ',
                  style: const TextStyle(fontSize: 16, color: Colors.purple),
                ),
              Text(
                value ?? 'Hesaplanmadı',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoroscopeSection() {
    // ... Bu widget'ta değişiklik yok ...
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.horoscopeData == null && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.fetchHoroscopes();
          });
        }
        if (provider.isLoading) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator()));
        }
        if (provider.errorMessage != null) {
          return Center(child: Text(provider.errorMessage!));
        }
        final dailyHoroscope =
            provider.horoscopeData?['daily']?['prediction_data']?['prediction'];
        if (dailyHoroscope == null) {
          return const SizedBox.shrink();
        }
        return _buildSectionCard(
          context,
          title: "Günün Yorumu",
          icon: Icons.comment,
          children: [
            Text(
              dailyHoroscope.toString(),
              style: const TextStyle(fontSize: 15, height: 1.5),
            )
          ],
        );
      },
    );
  }
}
