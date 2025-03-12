import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

class AuthService {
  final SolanaWalletAdapter _walletAdapter = SolanaWalletAdapter(
    AppIdentity(
      name: "Fitness Solana",
      uri: Uri.parse("https://fitness-solana.app"),
      icon: Uri.parse("https://fitness-solana.app/icon.png"),
    ),
    cluster: Cluster.devnet, // Change to mainnet for production
  );

  // Get nonce from the server
  Future<String> getNonce(String walletAddress) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getNonce}?walletAddress=$walletAddress'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'];
    } else {
      throw Exception('Failed to get nonce: ${response.body}');
    }
  }

  // Connect to wallet and sign message
  Future<Map<String, dynamic>> connectAndSignMessage(String message) async {
    try {
      // Request authorization from the wallet
      final authResult = await _walletAdapter.authorize();
      final walletAddress = authResult.accounts.first.address;
      
      // Sign the message with the wallet
      final signMessageResult = await _walletAdapter.signMessages(
        [message],
        addresses: [walletAddress],
      );
      
      final signature = signMessageResult.signedPayloads.first;
      
      return {
        'walletAddress': walletAddress,
        'message': message,
        'signature': signature,
      };
    } catch (e) {
      throw Exception('Failed to connect wallet or sign message: $e');
    }
  }

  // Login with wallet
  Future<Map<String, dynamic>> loginWithWallet() async {
    try {
      // First connect to wallet
      final authResult = await _walletAdapter.authorize();
      final walletAddress = authResult.accounts.first.address;
      
      // Get nonce from server
      final message = await getNonce(walletAddress);
      
      // Sign the message
      final signMessageResult = await _walletAdapter.signMessages(
        [message],
        addresses: [walletAddress],
      );
      
      final signature = signMessageResult.signedPayloads.first;
      
      // Send the signed message to server
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.walletLogin}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'walletAddress': walletAddress,
          'message': message,
          'signature': signature,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Wallet authentication failed: $e');
    }
  }

  // Sign up with additional user details
  Future<Map<String, dynamic>> signUp(String name, int age, DateTime dateOfBirth, String bio) async {
    try {
      // First login with wallet
      final loginResponse = await loginWithWallet();
      final token = loginResponse['token'];
      final walletAddress = loginResponse['user']['walletAddress'];
      
      // Update user profile with additional details
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.updateProfile}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'age': age,
          'dob': dateOfBirth.toIso8601String(),
          'bio': bio,
        }),
      );

      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body);
        // Return combined data
        return {
          'user': updatedData['user'],
          'token': token,
        };
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Get user profile
  Future<User> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userProfile}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to get user profile: ${response.body}');
    }
  }
} 