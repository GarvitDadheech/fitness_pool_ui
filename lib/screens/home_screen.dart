import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/pool_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    debugPrint("Token: ${authProvider.token}");
    if (authProvider.token != null) {
      await userProvider.fetchUserProfile(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Solana'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
            },
          ),
        ],
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User greeting
                    Text(
                      'Hello, ${userProvider.user?.name ?? 'Fitness Enthusiast'}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    
                    // Fitbit connection button (only if not connected)
                    if (!userProvider.isFitbitConnected)
                      Card(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Connect your Fitbit',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Connect your Fitbit account to participate in fitness pools and track your progress.',
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // This will be implemented later
                                  userProvider.connectFitbit();
                                },
                                icon: const Icon(Icons.fitness_center),
                                label: const Text('Connect with Fitbit'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Fitness Pools Section
                    const Text(
                      'Fitness Pools',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Hardcoded pools for now
                    PoolCard(
                      title: '10K Steps Challenge',
                      description: 'Complete 10,000 steps daily for 7 days.',
                      reward: '5 SOL',
                      participants: 24,
                      daysLeft: 5,
                      onTap: () {
                        // Do nothing for now
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    PoolCard(
                      title: 'Weekly Workout Warriors',
                      description: 'Complete at least 4 workouts this week.',
                      reward: '3 SOL',
                      participants: 18,
                      daysLeft: 3,
                      onTap: () {
                        // Do nothing for now
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    PoolCard(
                      title: 'Sleep Better Challenge',
                      description: 'Get 7+ hours of sleep for 5 consecutive nights.',
                      reward: '2 SOL',
                      participants: 12,
                      daysLeft: 7,
                      onTap: () {
                        // Do nothing for now
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 