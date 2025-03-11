import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFitbitConnected => _user?.isFitbitConnected ?? false;

  Future<void> fetchUserProfile(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.getUserProfile(token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // This would be implemented later when Fitbit integration is added
  Future<void> connectFitbit() async {
    // Implementation for Fitbit connection
    // For now, we'll just update the local state
    if (_user != null) {
      _user = User(
        id: _user!.id,
        walletAddress: _user!.walletAddress,
        name: _user!.name,
        age: _user!.age,
        dateOfBirth: _user!.dateOfBirth,
        bio: _user!.bio,
        isFitbitConnected: true,
      );
      notifyListeners();
    }
  }
} 