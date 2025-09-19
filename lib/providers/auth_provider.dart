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
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _appUser;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._apiService) {
    tryAutoLogin();
  }

  Future<bool> register(
      {required String username,
      required String email,
      required String password}) async {
    _errorMessage = null;
    try {
      final user = await _apiService.register(
          username: username, email: email, password: password);
      _appUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

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

  // --- NİHAİ VE DOĞRU YENİLEME MANTIĞI ---
  // Sunucudan gelen taze veriyi al ve ne olursa olsun dinleyicilere bildir.
  // Bu, tüm verilerin (isCalculated, burçlar, vb.) aynı anda güncellenmesini sağlar.
  Future<void> refreshUserProfile() async {
    try {
      final freshUser = await _apiService.getMe();
      _appUser = freshUser;
      print(
          "AuthProvider: Sunucudan taze veri alındı. UI güncellenmesi için BİLDİRİLİYOR.");
      notifyListeners();
    } catch (e) {
      print("Kullanıcı profili yenilenirken hata oluştu: $e");
    }
  }
}
