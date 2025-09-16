// lib/screens/activity_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/app_user.dart';
import '../services/api_service.dart';
// import 'profile_detail_screen.dart'; // TODO: Tıklama işlevi için eklenecek

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ActivityProvider(ctx.read<ApiService>()),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Consumer<ActivityProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.errorMessage != null) {
                return Center(child: Text(provider.errorMessage!));
              }
              if (provider.activityData == null) {
                return const Center(child: Text("Aktivite bulunamadı."));
              }

              final data = provider.activityData!;
              final allListsEmpty = data.matches.isEmpty &&
                  data.likers.isEmpty &&
                  data.visitors.isEmpty;

              return RefreshIndicator(
                onRefresh: provider.fetchActivityData,
                child: allListsEmpty
                    ? const Center(child: Text("Henüz bir aktiviteniz yok."))
                    : ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          if (data.matches.isNotEmpty)
                            _buildUserSection(
                                context, "Eşleşmeler", data.matches),
                          if (data.likers.isNotEmpty)
                            _buildUserSection(
                                context, "Seni Beğenenler", data.likers),
                          if (data.visitors.isNotEmpty)
                            _buildUserSection(context,
                                "Profilini Ziyaret Edenler", data.visitors),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection(
      BuildContext context, String title, List<AppUser> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            itemBuilder: (context, index) {
              return _buildUserAvatar(context, users[index]);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildUserAvatar(BuildContext context, AppUser user) {
    return GestureDetector(
      onTap: () {
        // TODO: ProfileDetailScreen'e yönlendirme yapılacak
        // Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileDetailScreen(user: user)));
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: user.profile.avatar != null
                  ? NetworkImage(user.profile.avatar!)
                  : null,
              child: user.profile.avatar == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              user.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
