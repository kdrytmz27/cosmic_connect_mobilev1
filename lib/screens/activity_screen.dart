// Lütfen bu kodu kopyalayıp lib/screens/activity_screen.dart dosyasının içine yapıştırın.

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
      child: const ActivityView(),
    );
  }
}

// Sekmeli yapıyı yönetmek için `TickerProviderStateMixin` ekliyoruz.
class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().fetchActivityData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // AppBar ekleyerek sekmeleri (TabBar) buraya yerleştiriyoruz.
      appBar: AppBar(
        title: const Text("Aktivite"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Seni Beğenenler"),
            Tab(text: "Ziyaretçiler"),
          ],
        ),
      ),
      body: SafeArea(
        // `Consumer` widget'ını en tepeye taşıyarak tüm alt widget'ların
        // provider'daki değişikliklerden haberdar olmasını sağlıyoruz.
        child: Consumer<ActivityProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorMessage != null) {
              return _buildErrorState(
                  context, provider.errorMessage!, provider.fetchActivityData);
            }
            if (provider.activityData == null) {
              return const Center(child: Text("Aktivite bulunamadı."));
            }

            final data = provider.activityData!;

            // Sekmelerin içeriğini `TabBarView` ile yönetiyoruz.
            return TabBarView(
              controller: _tabController,
              children: [
                // "Seni Beğenenler" Sekmesi
                _buildActivityList(
                  context,
                  users: data.likers,
                  emptyStateIcon: Icons.favorite_border,
                  emptyStateMessage: "Seni henüz kimse beğenmedi.",
                  onRefresh: provider.fetchActivityData,
                ),
                // "Ziyaretçiler" Sekmesi
                _buildActivityList(
                  context,
                  users: data.visitors,
                  emptyStateIcon: Icons.visibility_outlined,
                  emptyStateMessage: "Profilini henüz kimse ziyaret etmedi.",
                  onRefresh: provider.fetchActivityData,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Kullanıcı listesini veya boş ekranı gösteren yeniden kullanılabilir widget.
  Widget _buildActivityList(
    BuildContext context, {
    required List<AppUser> users,
    required IconData emptyStateIcon,
    required String emptyStateMessage,
    required Future<void> Function() onRefresh,
  }) {
    if (users.isEmpty) {
      return _buildEmptyState(context, emptyStateIcon, emptyStateMessage);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Daha kompakt bir görünüm için 3 sütun
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return _buildUserAvatar(context, users[index]);
        },
      ),
    );
  }

  // Avatar ve kullanıcı adını gösteren widget.
  Widget _buildUserAvatar(BuildContext context, AppUser user) {
    return GestureDetector(
      onTap: () {
        // TODO: ProfileDetailScreen'e yönlendirme yapılacak
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Hata durumunda gösterilecek ekran.
  Widget _buildErrorState(
      BuildContext context, String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tekrar Dene'),
            )
          ],
        ),
      ),
    );
  }

  // Liste boş olduğunda gösterilecek ekran.
  Widget _buildEmptyState(BuildContext context, IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // TODO: Keşfet sekmesine yönlendirme
            },
            child: const Text("Keşfet'te Yeni Kişilerle Tanış"),
          ),
        ],
      ),
    );
  }
}
