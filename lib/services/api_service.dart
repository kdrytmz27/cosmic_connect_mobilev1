// lib/services/api_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/app_user.dart';
import '../models/compatibility.dart';
import '../models/daily_match.dart';
import '../models/activity_data.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class PaginatedResponse<T> {
  final List<T> results;
  final String? nextUrl;
  PaginatedResponse({required this.results, this.nextUrl});
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => "ApiException: $message (Status Code: $statusCode)";
}

class ApiService {
  static const String _devBaseUrl = 'http://192.168.1.57:8000';
  static const String _prodBaseUrl = 'https://sizin.api.domaininiz.com';
  static const String baseUrl = kDebugMode ? _devBaseUrl : _prodBaseUrl;
  static const String _apiPath = '/api/v1';

  final http.Client _client;
  String? _token;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Future<String?> _getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      throw ApiException('Authentication token not found.', 401);
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token $token'
    };
  }

  Uri _buildUri(String endpoint) => Uri.parse('$baseUrl$_apiPath/$endpoint');

  Future<void> _persistToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<AppUser> register(
      {required String username,
      required String email,
      required String password}) async {
    final url = _buildUri('users/register/');
    final response = await _client.post(url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(
            {'username': username, 'email': email, 'password': password}));
    final data = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 201) {
      await _persistToken(data['token']);
      return AppUser.fromJson(data['user']);
    } else {
      final errorMessage = (data as Map).values.first.first;
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  Future<AppUser> login(
      {required String username, required String password}) async {
    final url = _buildUri('users/login/');
    final response = await _client.post(url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'username': username, 'password': password}));
    final data = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      await _persistToken(data['token']);
      _registerDeviceInBackground();
      return AppUser.fromJson(data['user']);
    } else {
      throw ApiException(data['non_field_errors']?.first ?? 'Giriş yapılamadı.',
          response.statusCode);
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }

  Future<AppUser> getMe() async {
    final url = _buildUri('users/me/');
    try {
      final response = await _client.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return appUserFromJson(utf8.decode(response.bodyBytes));
      } else {
        throw ApiException(
            'Kullanıcı bilgileri alınamadı.', response.statusCode);
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401) await _clearToken();
      rethrow;
    }
  }

  Future<AppUser> updateProfile(
      {Map<String, String>? profileData, File? avatarFile}) async {
    final url = _buildUri('users/me/');
    final request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(await _getHeaders());
    if (profileData != null) {
      profileData.forEach((key, value) {
        request.fields['profile.$key'] = value;
      });
    }
    if (avatarFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'profile.avatar', avatarFile.path,
          contentType: MediaType('image', 'jpeg')));
    }
    try {
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return AppUser.fromJson(responseData);
      } else {
        throw ApiException(responseData.toString(), response.statusCode);
      }
    } catch (e) {
      throw ApiException('Sunucuya bağlanılamadı.');
    }
  }

  Future<void> _registerDeviceInBackground() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        final url = _buildUri('users/devices/register/');
        await _client.post(url,
            headers: await _getHeaders(),
            body: json.encode({
              'fcm_token': fcmToken,
              'device_type': Platform.isAndroid ? 'android' : 'ios'
            }));
        debugPrint("FCM token başarıyla kaydedildi.");
      }
    } catch (e) {
      debugPrint("FCM token kaydı arka planda başarısız oldu: $e");
    }
  }

  Future<PaginatedResponse<Compatibility>> getDiscoverProfiles(
      {String? nextUrl, String? gender, int? minAge, int? maxAge}) async {
    final queryParams = {
      if (gender != null && gender != 'all') 'gender': gender,
      if (minAge != null) 'min_age': minAge.toString(),
      if (maxAge != null) 'max_age': maxAge.toString(),
    };
    final Uri url = nextUrl != null
        ? Uri.parse(nextUrl)
        : _buildUri('interactions/discover/').replace(
            queryParameters: queryParams.isNotEmpty ? queryParams : null);
    try {
      final response = await _client.get(url, headers: await _getHeaders());
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final List<Compatibility> results =
            compatibilityFromJson(json.encode(data['results']));
        return PaginatedResponse(results: results, nextUrl: data['next']);
      } else {
        throw ApiException("Keşfet profilleri alınamadı.", response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException("Sunucuya bağlanılamadı.");
    }
  }

  Future<DailyMatch?> getDailyMatch() async {
    final url = _buildUri('interactions/daily-match/');
    try {
      final response = await _client.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return dailyMatchFromJson(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ApiException("Günün eşleşmesi alınamadı.", response.statusCode);
      }
    } catch (e) {
      debugPrint("getDailyMatch hatası: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> getHoroscopes() async {
    final url = _buildUri('astrology/horoscopes/');
    try {
      final response = await _client.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw ApiException("Burç yorumları alınamadı.", response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException("Sunucuya bağlanılamadı.");
    }
  }

  Future<ActivityData> getActivityData() async {
    final url = _buildUri('interactions/activity/');
    try {
      final response = await _client.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return activityDataFromJson(utf8.decode(response.bodyBytes));
      } else {
        throw ApiException("Aktivite verileri alınamadı.", response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException("Sunucuya bağlanılamadı.");
    }
  }

  String? getTokenForWebSocket() {
    return _token;
  }

  Future<List<Conversation>> getConversations() async {
    final url = _buildUri('chat/conversations/');
    try {
      final response = await _client.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return conversationFromJson(utf8.decode(response.bodyBytes));
      } else {
        throw ApiException("Sohbetler alınamadı.", response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException("Sunucuya bağlanılamadı.");
    }
  }

  Future<List<Message>> getMessages(int conversationId) async {
    final url = _buildUri('chat/conversations/$conversationId/messages/');
    try {
      final response = await _client.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return messageFromJson(utf8.decode(response.bodyBytes));
      } else {
        throw ApiException("Mesajlar alınamadı.", response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException("Sunucuya bağlanılamadı.");
    }
  }

  Future<bool> verifyPurchase(
      {required String store,
      required String productId,
      required String purchaseToken,
      required String transactionId}) async {
    final url = _buildUri('subscriptions/verify-purchase/');
    final response = await _client.post(url,
        headers: await _getHeaders(),
        body: json.encode({
          'store': store,
          'product_id': productId,
          'purchase_token': purchaseToken,
          'transaction_id': transactionId
        }));
    if (response.statusCode == 200) {
      return true;
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      throw ApiException(
          data['error'] ?? 'Satın alma doğrulanamadı.', response.statusCode);
    }
  }
}
