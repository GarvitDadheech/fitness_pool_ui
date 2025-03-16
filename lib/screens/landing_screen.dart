import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import 'profile_form_screen.dart';
import '../main.dart'; // Import to access the global navigator key

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  // Method to navigate to profile form
  void _navigateToProfileForm() {
    debugPrint("Executing navigation method");
    Navigator.of(context).pushReplacementNamed('/profile_form');
    debugPrint("Navigation method completed");
  }

  void _connectWallet() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show loading state
    setState(() {});
    
    // Use the complete flow method that handles navigation
    final success = await authProvider.completeWalletVerificationFlow();
    
    // Only show error if still mounted and there was an error
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to complete wallet verification'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or App Name
                const Icon(
                  Icons.fitness_center,
                  size: 100,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                Text(
                  'Fitness Solana',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Track your fitness activities and earn rewards',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 32),
                
                // App description
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: const [
                      ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Connect your Solana wallet'),
                        subtitle: Text('Secure authentication with your wallet'),
                      ),
                      ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Track your fitness activities'),
                        subtitle: Text('Sync with Fitbit and other fitness trackers'),
                      ),
                      ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Join fitness pools'),
                        subtitle: Text('Compete with others and earn rewards'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                
                // Connect wallet button
                AuthButton(
                  text: 'Connect Wallet to Continue',
                  isLoading: authProvider.isLoading,
                  onPressed: _connectWallet,
                ),
                const SizedBox(height: 16),
                // Test button for direct navigation (for debugging)
                if (kDebugMode) // Only show in debug mode
                  TextButton(
                    onPressed: _navigateToProfileForm,
                    child: const Text('Debug: Go to Profile Form'),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'You need a Solana wallet to use this app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 