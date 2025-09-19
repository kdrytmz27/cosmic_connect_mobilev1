// Lütfen bu kodu kopyalayıp lib/providers/discover_provider.dart dosyasının içine yapıştırın.

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/compatibility.dart';
import '../models/daily_match.dart';
import '../widgets/filter_sheet.dart';
import 'auth_provider.dart';

class DiscoverProvider with ChangeNotifier {
  final ApiService _apiService;
  AuthProvider _authProvider;

  // --- NİHAİ GÜVENCE MEKANİZMASI ---
  // Bu bayrak, loadInitialData'nın sadece BİR KEZ çağrılmasını garanti eder.
  bool _initialDataLoaded = false;

  DailyMatch? _dailyMatch;
  List<Compatibility> _compatibilities = [];
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _nextPageUrl;

  String _genderFilter = 'all';
  RangeValues _ageRangeFilter = const RangeValues(18, 65);

  DailyMatch? get dailyMatch => _dailyMatch;
  List<Compatibility> get compatibilities => _compatibilities;
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _nextPageUrl != null;
  String get genderFilter => _genderFilter;
  RangeValues get ageRangeFilter => _ageRangeFilter;

  DiscoverProvider(this._apiService, this._authProvider);

  // Bu metod, ProxyProvider tarafından AuthProvider her değiştiğinde çağrılır.
  void update(AuthProvider newAuthProvider) {
    _authProvider = newAuthProvider;

    // NİHAİ VE EN SAĞLAM MANTIK:
    // 1. Harita hesaplanmış mı? -> EVET
    // 2. Bu durum için veriyi daha önce yükledik mi? -> HAYIR
    // O zaman veriyi ŞİMDİ YÜKLE ve bayrağı kaldır.
    if (_authProvider.user?.profile.isBirthChartCalculated == true &&
        !_initialDataLoaded) {
      _initialDataLoaded = true;
      print(
          "DiscoverProvider: AuthProvider güncellemesi algılandı. Keşfet verileri yükleniyor.");
      loadInitialData();
    }
  }

  Future<void> loadInitialData() async {
    _isLoadingInitial = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getDailyMatch(),
        _apiService.getDiscoverProfiles(
          gender: _genderFilter,
          minAge: _ageRangeFilter.start.round(),
          maxAge: _ageRangeFilter.end.round(),
        ),
      ]);
      _dailyMatch = results[0] as DailyMatch?;
      final paginatedResponse = results[1] as PaginatedResponse<Compatibility>;
      _compatibilities = paginatedResponse.results;
      _nextPageUrl = paginatedResponse.nextUrl;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreProfiles() async {
    if (_isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final paginatedResponse = await _apiService.getDiscoverProfiles(
        nextUrl: _nextPageUrl,
        gender: _genderFilter,
        minAge: _ageRangeFilter.start.round(),
        maxAge: _ageRangeFilter.end.round(),
      );
      _compatibilities.addAll(paginatedResponse.results);
      _nextPageUrl = paginatedResponse.nextUrl;
    } on ApiException catch (e) {
      debugPrint("Daha fazla profil yüklenemedi: ${e.message}");
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void applyFilters(FilterValues filters) {
    _genderFilter = filters.gender;
    _ageRangeFilter = filters.ageRange;
    loadInitialData();
  }
}
