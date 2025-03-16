import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late FlutterSecureStorage _secureStorage;
  late SharedPreferences _prefs;
  
  Future<void> init() async {
    _secureStorage = const FlutterSecureStorage();
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'jwt_token');
  }
  
  // Store wallet connection state
  Future<void> saveWalletConnectionState(bool isConnected) async {
    await _prefs.setBool('wallet_connected', isConnected);
  }
  
  Future<bool> isWalletConnected() async {
    return _prefs.getBool('wallet_connected') ?? false;
  }
  
  // Store wallet address
  Future<void> saveWalletAddress(String address) async {
    await _prefs.setString('wallet_address', address);
  }
  
  Future<String?> getWalletAddress() async {
    return _prefs.getString('wallet_address');
  }
  
  Future<void> deleteWalletAddress() async {
    await _prefs.remove('wallet_address');
  }
} 