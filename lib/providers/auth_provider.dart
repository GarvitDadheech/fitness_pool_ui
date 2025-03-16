import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../main.dart'; // Import to access the global navigator key

class AuthProvider with ChangeNotifier {
  final StorageService _storageService;
  final AuthService _authService = AuthService();
  
  String? _token;
  String? _walletAddress;
  bool _isLoading = false;
  String? _error;
  bool _isWalletConnected = false;
  String? _nonce;
  bool _isWalletVerified = false;

  AuthProvider(this._storageService) {
    _loadToken();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  String? get walletAddress => _walletAddress;
  bool get isWalletConnected => _isWalletConnected;
  bool get isWalletVerified => _isWalletVerified;
  String? get nonce => _nonce;
  bool get hasToken => _token != null;

  Future<void> _loadToken() async {
    _token = await _storageService.getToken();
    _walletAddress = await _storageService.getWalletAddress();
    _isWalletConnected = _walletAddress != null;
    notifyListeners();
  }

  Future<bool> isAuthenticated() async {
    if (_token == null) {
      _token = await _storageService.getToken();
    }
    return _token != null;
  }

  // Connect wallet
  Future<bool> connectWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _walletAddress = await _authService.connectWallet();
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

  // Disconnect wallet
  Future<bool> disconnectWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Clear wallet data
      _walletAddress = null;
      _isWalletConnected = false;
      _isWalletVerified = false;
      _nonce = null;
      await _storageService.deleteWalletAddress();
      
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

  // Get nonce for wallet verification
  Future<bool> getNonce() async {
    if (_walletAddress == null) {
      _error = "Wallet not connected";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _nonce = await _authService.getNonce(_walletAddress!);
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

  // Verify wallet with nonce
  Future<bool> verifyWallet() async {
    if (_walletAddress == null) {
      _error = "Wallet not connected";
      notifyListeners();
      return false;
    }

    if (_nonce == null) {
      _error = "Nonce not generated";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Verify wallet by signing the nonce
      final isVerified = await _authService.verifyWallet(_walletAddress!, _nonce!);
      
      if (!isVerified) {
        _error = "Wallet verification failed";
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      _isWalletVerified = true;
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

  // Create user profile
  Future<bool> createProfile({
    required String name,
    required String gender,
    required DateTime dateOfBirth,
    required String bio,
  }) async {
    if (_walletAddress == null) {
      _error = "Wallet not connected";
      notifyListeners();
      return false;
    }

    if (!_isWalletVerified) {
      _error = "Wallet not verified";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create profile
      final response = await _authService.createProfile(
        walletAddress: _walletAddress!,
        name: name,
        gender: gender,
        dob: dateOfBirth,
        bio: bio,
      );

      _token = response['token'];
      await _storageService.saveToken(_token!);
      await _storageService.saveWalletAddress(_walletAddress!);
      
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
    await _storageService.deleteWalletAddress();
    _token = null;
    _walletAddress = null;
    _isWalletConnected = false;
    _isWalletVerified = false;
    _nonce = null;
    notifyListeners();
  }

  // Complete wallet verification flow
  Future<bool> completeWalletVerificationFlow() async {
    // Step 1: Connect wallet
    final connectSuccess = await connectWallet();
    if (!connectSuccess) {
      return false;
    }
    
    // Step 2: Get nonce
    final nonceSuccess = await getNonce();
    if (!nonceSuccess) {
      return false;
    }
    
    // Step 3: Verify wallet
    final verifySuccess = await verifyWallet();
    if (!verifySuccess) {
      return false;
    }
    
    // Step 4: Navigate to profile form
    debugPrint("Wallet verification flow completed successfully, navigating...");
    _navigateToProfileForm();
    
    return true;
  }
  
  // Navigate to profile form using the global navigator key
  void _navigateToProfileForm() {
    debugPrint("Navigating to profile form from provider");
    // Use a small delay to ensure navigation happens after current frame
    Future.delayed(const Duration(milliseconds: 100), () {
      navigatorKey.currentState?.pushReplacementNamed('/profile_form');
      debugPrint("Navigation completed from provider");
    });
  }
} 