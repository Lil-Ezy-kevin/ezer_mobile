import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Exception levée pour toute erreur renvoyée par l'API (message lisible côté UI).
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  /// Changez cette valeur selon l'environnement :
  /// - Émulateur Android : http://10.0.2.2:5000/api
  /// - Simulateur iOS / web : http://127.0.0.1:5000/api
  /// - Appareil physique / production : https://votre-api.onrender.com/api
  static const String baseUrl = String.fromEnvironment(
    'EZER_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );

  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  bool get isLoggedIn => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  dynamic _handle(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    final message = (body is Map && body['error'] != null)
        ? body['error'].toString()
        : 'Une erreur est survenue (${res.statusCode}).';
    throw ApiException(message, res.statusCode);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final res = await http.get(uri, headers: _headers);
    return _handle(res);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.post(uri, headers: _headers, body: jsonEncode(body ?? {}));
    return _handle(res);
  }

  // ---------- Auth ----------

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String phone = '',
    String city = '',
    String service = '',
  }) async {
    final data = await post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone': phone,
      'city': city,
      'service': service,
    });
    await _saveToken(data['access_token']);
    return data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await post('/auth/login', body: {'email': email, 'password': password});
    await _saveToken(data['access_token']);
    return data;
  }

  Future<Map<String, dynamic>> me() async => await get('/me');

  // ---------- Prestataires ----------

  Future<List<dynamic>> searchProviders({String service = '', String city = ''}) async {
    final query = <String, String>{};
    if (service.isNotEmpty) query['service'] = service;
    if (city.isNotEmpty) query['city'] = city;
    return await get('/providers', query: query);
  }

  Future<Map<String, dynamic>> providerProfile(int providerId) async =>
      await get('/providers/$providerId');

  Future<void> addReview(int providerId, int rating, String comment) async {
    await post('/providers/$providerId/reviews', body: {'rating': rating, 'comment': comment});
  }

  // ---------- Demandes ----------

  Future<Map<String, dynamic>> makeRequest(int providerId, Map<String, dynamic> data) async =>
      await post('/providers/$providerId/request', body: data);

  Future<void> updateRequestStatus(int requestId, String status) async {
    await post('/requests/$requestId/status', body: {'status': status});
  }

  // ---------- Tableaux de bord ----------

  Future<Map<String, dynamic>> clientDashboard() async => await get('/client/dashboard');

  Future<Map<String, dynamic>> providerDashboard() async => await get('/provider/dashboard');

  Future<Map<String, dynamic>> adminDashboard({String q = '', String status = ''}) async {
    final query = <String, String>{};
    if (q.isNotEmpty) query['q'] = q;
    if (status.isNotEmpty) query['status'] = status;
    return await get('/admin/dashboard', query: query);
  }

  // ---------- Paiements ----------

  Future<Map<String, dynamic>> paymentInfo(int requestId) async =>
      await get('/requests/$requestId/payment');

  Future<Map<String, dynamic>> makePayment(int requestId, Map<String, dynamic> data) async =>
      await post('/requests/$requestId/payment', body: data);

  Future<Map<String, dynamic>> paymentReceipt(int requestId) async =>
      await get('/payments/$requestId/receipt');

  // ---------- Notifications ----------

  Future<List<dynamic>> notifications() async => await get('/notifications');

  // ---------- Admin actions ----------

  Future<void> adminVerifyProvider(int userId) async =>
      await post('/admin/providers/$userId/verify');

  Future<void> adminUnverifyProvider(int userId) async =>
      await post('/admin/providers/$userId/unverify');

  Future<void> adminToggleUser(int userId) async =>
      await post('/admin/users/$userId/toggle');

  Future<void> adminRequestStatus(int requestId, String status) async =>
      await post('/admin/requests/$requestId/status', body: {'status': status});

  Future<void> adminPaymentStatus(int paymentId, String status) async =>
      await post('/admin/payments/$paymentId/status', body: {'status': status});
}
