// lib/providers/activity_provider.dart

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/activity_data.dart';

class ActivityProvider with ChangeNotifier {
  final ApiService _apiService;

  ActivityData? _activityData;
  bool _isLoading = true;
  String? _errorMessage;

  ActivityData? get activityData => _activityData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ActivityProvider(this._apiService) {
    fetchActivityData();
  }

  Future<void> fetchActivityData() async {
    _isLoading = true;
    _errorMessage = null;
    // Veri yenilenirken eski verinin görünmemesi için notifyListeners'ı burada çağırabiliriz.
    notifyListeners();

    try {
      // Bu fonksiyon henüz ApiService'te yok, bir sonraki adımda ekleyeceğiz.
      _activityData = await _apiService.getActivityData();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "Aktivite verileri alınamadı.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
