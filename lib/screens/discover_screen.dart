// Lütfen bu kodu kopyalayıp lib/screens/discover_screen.dart dosyasının içine yapıştırın.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/discover_provider.dart';
import '../models/app_user.dart';
import '../models/daily_match.dart';
import 'profile_detail_screen.dart';
import '../widgets/profile_card.dart';
import '../widgets/filter_sheet.dart';
import '../services/api_service.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => DiscoverProvider(
        ctx.read<ApiService>(),
        ctx.read<AuthProvider>(),
      ),
      child: const DiscoverView(),
    );
  }
}

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});
  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoverProvider>().loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<DiscoverProvider>().fetchMoreProfiles();
    }
  }

  void _openFilterSheet(BuildContext context) async {
    final provider = context.read<DiscoverProvider>();
    final result = await showModalBottomSheet<FilterValues>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FilterSheet(
          initialFilters: FilterValues(
            gender: provider.genderFilter,
            ageRange: provider.ageRangeFilter,
          ),
        );
      },
    );
    if (result != null) {
      provider.applyFilters(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<DiscoverProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.errorMessage != null) {
                    return Center(child: Text(provider.errorMessage!));
                  }
                  return _buildBody(provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // AuthProvider'a artık burada ihtiyacımız yok.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
      child: Row(
        children: [
          Text('Keşfet',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => _openFilterSheet(context),
            icon: const Icon(Icons.filter_list_rounded, size: 20),
            label: const Text('Filtrele'),
          ),
          // --- GÖREV 1 DEĞİŞİKLİĞİ: Çıkış Yap IconButton buradan KALDIRILDI ---
        ],
      ),
    );
  }

  Widget _buildBody(DiscoverProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.loadInitialData,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (provider.dailyMatch != null)
            SliverToBoxAdapter(
                child: _buildDailyMatchCard(provider.dailyMatch!)),
          if (provider.compatibilities.isEmpty && !provider.isLoadingInitial)
            const SliverFillRemaining(
                child: Center(child: Text('Gösterilecek kimse bulunamadı.'))),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final compatibility = provider.compatibilities[index];
                  return ProfileCard(
                    compatibility: compatibility,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfileDetailScreen(user: compatibility.user),
                        ),
                      );
                    },
                  );
                },
                childCount: provider.compatibilities.length,
              ),
            ),
          ),
          if (provider.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDailyMatchCard(DailyMatch dailyMatch) {
    final AppUser user = dailyMatch.matchedUser;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfileDetailScreen(user: user),
            ),
          );
        },
        child: Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text("Günün Eşleşmesi",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.profile.avatar != null
                      ? NetworkImage(user.profile.avatar!)
                      : null,
                ),
                const SizedBox(height: 12),
                Text('${user.username}, ${user.profile.age ?? ''}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '☀️ ${user.profile.sunSignDisplay ?? '-'}   🌙 ${user.profile.moonSignDisplay ?? '-'}',
                  style: TextStyle(color: Colors.white.withAlpha(204)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
