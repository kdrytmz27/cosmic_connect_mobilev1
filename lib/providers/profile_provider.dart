// lib/providers/profile_provider.dart

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService;

  Map<String, dynamic>? _horoscopeData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get horoscopeData => _horoscopeData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProfileProvider(this._apiService);

  Future<void> fetchHoroscopes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Bu fonksiyon henüz ApiService'te yok, bir sonraki adımda ekleyeceğiz.
      _horoscopeData = await _apiService.getHoroscopes();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "Burç yorumları alınamadı.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
