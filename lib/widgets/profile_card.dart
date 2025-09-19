// Lütfen bu kodu kopyalayıp lib/widgets/profile_card.dart dosyasının içine yapıştırın.

import 'package:flutter/material.dart';
import '../models/compatibility.dart';
import '../models/app_user.dart';

class ProfileCard extends StatelessWidget {
  final Compatibility compatibility;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.compatibility,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppUser user = compatibility.user;
    final String? avatarUrl = user.profile.avatar;

    return Card(
      clipBehavior: Clip.antiAlias,
      // --- YAZIM HATASI DÜZELTİLDİ ---
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: GridTile(
          footer: _buildFooter(context, user, compatibility.score),
          child: Hero(
            tag: 'profile-avatar-${user.id}',
            child: Container(
              color: Colors.grey[200],
              child: avatarUrl != null
                  ? FadeInImage.assetNetwork(
                      // Lütfen projenize bir placeholder resmi eklediğinizden emin olun
                      // Örneğin: assets/images/placeholder.png
                      placeholder: 'assets/images/placeholder.png',
                      image: avatarUrl,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person,
                            size: 60, color: Colors.grey);
                      },
                    )
                  : const Icon(Icons.person, size: 60, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppUser user, int score) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(153), // 0.6 opacity
            Colors.black.withAlpha(204), // 0.8 opacity
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${user.username}, ${user.profile.age ?? ''}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              shadows: [Shadow(blurRadius: 2.0, color: Colors.black54)],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '☀️ ${user.profile.sunSignDisplay ?? '-'}  '
                  '🌙 ${user.profile.moonSignDisplay ?? '-'}  '
                  '✨ ${user.profile.risingSignDisplay ?? '-'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128), // 0.5 opacity
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getScoreColor(score), width: 1),
                ),
                child: Text(
                  '$score% Uyum',
                  style: TextStyle(
                    color: _getScoreColor(score),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score > 85) return Colors.greenAccent;
    if (score > 70) return Colors.yellow;
    if (score > 50) return Colors.orange;
    return Colors.redAccent;
  }
}
