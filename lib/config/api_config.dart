class ApiConfig {
  static const String baseUrl = 'https://ba22-223-185-19-51.ngrok-free.app/api';
  
  // Auth endpoints
  static const String getNonce = '/auth/nonce';
  static const String verifyNonce = '/auth/verify-nonce';
  static const String createProfile = '/auth/profile';
  
  // User endpoints
  static const String userProfile = '/user/profile';
} 