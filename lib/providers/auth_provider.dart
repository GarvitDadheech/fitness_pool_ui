import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService;
  final AuthService _authService = AuthService();
  
  String? _token;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._storageService) {
    _loadToken();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  bool get hasToken => _token != null;

  Future<void> _loadToken() async {
    _token = await _storageService.getToken();
    notifyListeners();
  }

  Future<bool> isAuthenticated() async {
    if (_token == null) {
      _token = await _storageService.getToken();
    }
    return _token != null;
  }

  Future<bool> signUp(String walletAddress, String name, int age, DateTime dateOfBirth, String bio) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.signUp(walletAddress, name, age, dateOfBirth, bio);
      _token = response['token'];
      await _storageService.saveToken(_token!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String walletAddress) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(walletAddress);
      _token = response['token'];
      await _storageService.saveToken(_token!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
    _token = null;
    notifyListeners();
  }
} 