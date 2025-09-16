// lib/screens/profile_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/app_user.dart';

class ProfileDetailScreen extends StatelessWidget {
  final AppUser user;

  const ProfileDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = user.profile.avatar;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(user.username),
              background: Hero(
                tag: 'profile-avatar-${user.id}',
                child: Container(
                  color: Colors.grey[200],
                  child: avatarUrl != null
                      ? Image.network(avatarUrl, fit: BoxFit.cover)
                      : const Icon(Icons.person, size: 100, color: Colors.grey),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hakkında',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.profile.bio.isNotEmpty
                            ? user.profile.bio
                            : 'Henüz hakkında bir şey yazmamış.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Divider(height: 40),
                      Text(
                        'Astrolojik Bilgiler',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildAstroInfoRow('Güneş', user.profile.sunSignDisplay),
                      _buildAstroInfoRow('Ay', user.profile.moonSignDisplay),
                      _buildAstroInfoRow(
                          'Yükselen', user.profile.risingSignDisplay),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAstroInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value ?? 'Bilinmiyor',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
