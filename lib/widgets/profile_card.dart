// lib/widgets/profile_card.dart

import 'package:flutter/material.dart'; // <<<--- EKSİK OLAN EN ÖNEMLİ SATIR EKLENDİ ---
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: GridTile(
          footer: _buildFooter(context, user),
          child: Hero(
            tag: 'profile-avatar-${user.id}', // Animasyon için benzersiz tag
            child: Container(
              color: Colors.grey[200],
              child: avatarUrl != null
                  ? FadeInImage.assetNetwork(
                      // Lütfen projenize bir placeholder resmi eklediğinizden emin olun
                      // assets/images/placeholder.png
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

  Widget _buildFooter(BuildContext context, AppUser user) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.8),
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
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '☀️ ${user.profile.sunSignDisplay ?? '-'}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                '${compatibility.score}% Uyum',
                style: const TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
