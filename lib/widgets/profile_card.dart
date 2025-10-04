// lib/widgets/profile_card.dart

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: GridTile(
          footer: _buildFooter(
              context, user, compatibility.score, compatibility.breakdown),
          child: Hero(
            tag: 'profile-avatar-${user.id}',
            child: Container(
              color: Colors.grey[200],
              child: avatarUrl != null
                  ? FadeInImage.assetNetwork(
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

  // --- FAZ 2 DEĞİŞİKLİĞİ: breakdown parametresi eklendi ---
  Widget _buildFooter(BuildContext context, AppUser user, int score,
      Map<String, dynamic> breakdown) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(180), // 0.7 opacity
            Colors.black.withAlpha(230), // 0.9 opacity
          ],
          stops: const [0.0, 0.3, 1.0],
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
          Text(
            '☀️ ${user.profile.sunSignDisplay ?? '-'}  '
            '🌙 ${user.profile.moonSignDisplay ?? '-'}  '
            '✨ ${user.profile.risingSignDisplay ?? '-'}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // --- FAZ 2 DEĞİŞİKLİĞİ: Uyumluluk dökümü grafikleri eklendi ---
          _buildBreakdownBars(breakdown),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
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
          ),
        ],
      ),
    );
  }

  // --- FAZ 2 DEĞİŞİKLİĞİ: Dökümü görselleştirmek için yeni widget ---
  Widget _buildBreakdownBars(Map<String, dynamic> breakdown) {
    // breakdown map'i boşsa, hiçbir şey gösterme
    if (breakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    // Map'i widget listesine dönüştür
    final List<Widget> bars = breakdown.entries.map((entry) {
      // Skorun integer olduğundan emin ol, değilse 0 kabul et
      final score = (entry.value is int) ? entry.value : 0;
      return _buildTitledProgressBar(
        title: entry.key,
        value: score / 100.0, // Değeri 0-1 aralığına getir
        color: _getScoreColor(score),
      );
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bars,
    );
  }

  // --- FAZ 2 DEĞİŞİKLİĞİ: Başlıklı ilerleme çubuğu için yardımcı widget ---
  Widget _buildTitledProgressBar({
    required String title,
    required double value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
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
