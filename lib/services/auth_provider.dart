import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = true;

  AppUser? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  /// Appelé au démarrage : charge le token stocké et récupère le profil.
  Future<void> bootstrap() async {
    await ApiService.instance.loadToken();
    if (ApiService.instance.isLoggedIn) {
      try {
        final data = await ApiService.instance.me();
        _user = AppUser.fromJson(data);
      } catch (_) {
        await ApiService.instance.clearToken();
        _user = null;
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await ApiService.instance.login(email, password);
    _user = AppUser.fromJson(data['user']);
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String phone = '',
    String city = '',
    String service = '',
  }) async {
    final data = await ApiService.instance.register(
      name: name, email: email, password: password, role: role,
      phone: phone, city: city, service: service,
    );
    _user = AppUser.fromJson(data['user']);
    notifyListeners();
  }

  Future<void> refreshMe() async {
    final data = await ApiService.instance.me();
    _user = AppUser.fromJson(data);
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService.instance.clearToken();
    _user = null;
    notifyListeners();
  }
}
