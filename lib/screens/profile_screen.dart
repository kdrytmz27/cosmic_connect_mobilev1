// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../models/app_user.dart';
import '../services/api_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthProvider'ı genel kullanıcı verileri için dinliyoruz.
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    // ProfileProvider'ı bu ekrana özel veriler için oluşturuyoruz.
    return ChangeNotifierProvider(
      create: (ctx) => ProfileProvider(ctx.read<ApiService>()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profilim'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // === DEĞİŞİKLİK BURADA ===
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
                // =========================
              },
            ),
          ],
        ),
        body: user == null
            ? const Center(child: Text("Kullanıcı bulunamadı."))
            : RefreshIndicator(
                onRefresh: () => authProvider.refreshUser(),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildProfileHeader(context, user),
                    const SizedBox(height: 24),
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
                    // Burç Yorumları Bölümü
                    _buildHoroscopeSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppUser user) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value ?? 'Hesaplanmadı',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Burç Yorumlarını gösteren yeni widget
  Widget _buildHoroscopeSection() {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        // Ekran oluşturulduğunda verileri çek
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
          return const SizedBox.shrink(); // Yorum yoksa bir şey gösterme
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
