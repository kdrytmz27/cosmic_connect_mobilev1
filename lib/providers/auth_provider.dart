// Lütfen bu kodu kopyalayıp lib/providers/auth_provider.dart dosyasının içine yapıştırın.

import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/app_user.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;

  AppUser? _appUser;
  AuthStatus _status = AuthStatus.uninitialized;
  bool _isLoading = false; // Bu genel isLoading, diğer metodlar için kalabilir
  String? _errorMessage;

  AppUser? get user => _appUser;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._apiService) {
    tryAutoLogin();
  }

  // --- ANA DEĞİŞİKLİK BURADA: register metodu sadeleştirildi ---
  Future<bool> register(
      {required String username,
      required String email,
      required String password}) async {
    // Bu metod artık kendi içinde _isLoading'i yönetmiyor ve notifyListeners çağırmıyor.
    // Sadece API'ye gidip, başarılı olursa durumu güncelliyor.
    _errorMessage = null;
    try {
      final user = await _apiService.register(
          username: username, email: email, password: password);
      _appUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners(); // Sadece BAŞARILI olduğunda ve TEK SEFERDE durum değişikliğini bildir.
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      // Başarısızlık durumunda state'i bozmuyoruz, sadece hata mesajını set ediyoruz.
      // Bu sayede UI tekrar butona basmaya izin verir.
      notifyListeners();
      return false;
    }
  }

  // Diğer metodlar aynı kalabilir...
  Future<void> tryAutoLogin() async {
    _status = AuthStatus.uninitialized;
    notifyListeners();
    try {
      _appUser = await _apiService.getMe();
      _status = AuthStatus.authenticated;
    } catch (e) {
      _appUser = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(
      {required String username, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _appUser =
          await _apiService.login(username: username, password: password);
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(
      {Map<String, String>? profileData, File? avatarFile}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updatedUser = await _apiService.updateProfile(
        profileData: profileData,
        avatarFile: avatarFile,
      );
      _appUser = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _appUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (isAuthenticated) {
      try {
        _appUser = await _apiService.getMe();
        notifyListeners();
      } catch (e) {
        await logout();
      }
    }
  }
}
