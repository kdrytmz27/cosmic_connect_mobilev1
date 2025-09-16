// lib/providers/discover_provider.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/compatibility.dart';
import '../models/daily_match.dart';
import '../widgets/filter_sheet.dart'; // FilterValues için import

class DiscoverProvider with ChangeNotifier {
  final ApiService _apiService;

  DailyMatch? _dailyMatch;
  List<Compatibility> _compatibilities = [];
  bool _isLoadingInitial = true;
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

  DiscoverProvider(this._apiService) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoadingInitial = true;
    _errorMessage = null;
    _compatibilities = [];
    _nextPageUrl = null;
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
    } catch (e) {
      _errorMessage = "Bilinmeyen bir hata oluştu.";
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
        // Önemli: Sonraki sayfa istekleri de mevcut filtreleri içermelidir.
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
