class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Auth endpoints
  static const String getNonce = '/auth/nonce';
  static const String walletLogin = '/auth/wallet-login';
  
  // User endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
} 