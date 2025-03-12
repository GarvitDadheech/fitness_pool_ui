import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService;
  final AuthService _authService = AuthService();
  
  String? _token;
  String? _walletAddress;
  bool _isLoading = false;
  String? _error;
  bool _isWalletConnected = false;

  AuthProvider(this._storageService) {
    _loadToken();
    _loadWalletState();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  String? get walletAddress => _walletAddress;
  bool get isWalletConnected => _isWalletConnected;
  bool get hasToken => _token != null;

  Future<void> _loadToken() async {
    _token = await _storageService.getToken();
    notifyListeners();
  }
  
  Future<void> _loadWalletState() async {
    _isWalletConnected = await _storageService.isWalletConnected();
    _walletAddress = await _storageService.getWalletAddress();
    notifyListeners();
  }

  Future<bool> isAuthenticated() async {
    if (_token == null) {
      _token = await _storageService.getToken();
    }
    return _token != null;
  }

  // Connect wallet and login
  Future<bool> connectWalletAndLogin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.loginWithWallet();
      _token = response['token'];
      _walletAddress = response['user']['walletAddress'];
      
      await _storageService.saveToken(_token!);
      await _storageService.saveWalletAddress(_walletAddress!);
      await _storageService.saveWalletConnectionState(true);
      
      _isWalletConnected = true;
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

  // Sign up with additional user details
  Future<bool> signUp(String name, int age, DateTime dateOfBirth, String bio) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.signUp(name, age, dateOfBirth, bio);
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
    await _storageService.saveWalletConnectionState(false);
    _token = null;
    _isWalletConnected = false;
    notifyListeners();
  }
} 