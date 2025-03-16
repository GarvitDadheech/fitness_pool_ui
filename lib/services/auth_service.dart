import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:solana/solana.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

class AuthService {
  final SolanaWalletAdapter _walletAdapter = SolanaWalletAdapter(
    const AppIdentity(
      name: "Fitness Solana",
    ),
    cluster: Cluster.mainnet, // Change to mainnet for production
  );

  // Store the base64 address when connecting
  String? _base64Address;

  // Connect wallet and get address
  Future<String> connectWallet() async {
    try {
      final authResult = await _walletAdapter.authorize();
      
      // Check if user cancelled the wallet connection
      if (authResult.accounts.isEmpty) {
        throw Exception('Wallet connection cancelled by user');
      }
      
      // Store the base64 address for later use
      _base64Address = authResult.accounts.first.address;
      
      // Convert base64 address to base58 (Solana public key format)
      final bytes = base64.decode(_base64Address!);
      final publicKey = Ed25519HDPublicKey(bytes);
      final walletAddress = publicKey.toBase58();
      
      debugPrint("Connected wallet address: $walletAddress");
      return walletAddress;
    } catch (e) {
      if (e.toString().contains('User rejected') || 
          e.toString().contains('cancelled by user') ||
          e.toString().contains('No wallet found')) {
        throw Exception('Wallet connection cancelled: ${e.toString()}');
      } else {
        throw Exception('Wallet connection failed: ${e.toString()}');
      }
    }
  }

  // Get nonce from the server
  Future<String> getNonce(String walletAddress) async {
    try {
      debugPrint("Getting nonce from server...");
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getNonce}?walletAddress=$walletAddress'),
      );
      debugPrint("Response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'];
      } else {
        throw Exception('Failed to get nonce: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get nonce: $e');
    }
  }

  // Verify wallet by signing nonce
  Future<bool> verifyWallet(String walletAddress, String message) async {
    try {
      if (_base64Address == null) {
        throw Exception('Wallet not connected properly');
      }
      debugPrint("Base64 address: $_base64Address");
      // Sign the message using the stored base64 address
      final signMessageResult = await _walletAdapter.signMessages(
        [message],
        addresses: [_base64Address!],
      );
      
      final signature = signMessageResult.signedPayloads.first;
      debugPrint("Signature: $signature");
      // Verify the signature with the server
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyNonce}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'walletAddress': walletAddress,
          'message': message,
          'signature': signature,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isValid'] ?? false;
      } else {
        throw Exception('Failed to verify wallet: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('User rejected')) {
        throw Exception('Message signing cancelled by user');
      } else {
        throw Exception('Failed to verify wallet: $e');
      }
    }
  }

  // Create user profile
  Future<Map<String, dynamic>> createProfile({
    required String walletAddress,
    required String name,
    required String gender,
    required DateTime dob,
    required String bio,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createProfile}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'walletAddress': walletAddress,
          'name': name,
          'gender': gender.toLowerCase(),
          'dob': dob.toIso8601String().split('T')[0],
          'bio': bio,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Profile creation failed: $e');
    }
  }

  // Get user profile
  Future<User> getUserProfile(String token) async {
    debugPrint("Getting user profile with token: $token");
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userProfile}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['user'] != null) {
          return User.fromJson(data['user']);
        } else {
          throw Exception('User data not found in response');
        }
      } else {
        throw Exception('Failed to get user profile: ${response.body}');
      }
    } catch (e) {
      debugPrint("Error getting user profile: $e");
      rethrow;
    }
  }
} 