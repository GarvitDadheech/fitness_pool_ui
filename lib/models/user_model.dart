class User {
  final String id;
  final String walletAddress;
  final String name;
  final int age;
  final DateTime dateOfBirth;
  final String bio;
  final bool isFitbitConnected;

  User({
    required this.id,
    required this.walletAddress,
    required this.name,
    required this.age,
    required this.dateOfBirth,
    required this.bio,
    this.isFitbitConnected = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      walletAddress: json['walletAddress'],
      name: json['name'],
      age: json['age'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      bio: json['bio'],
      isFitbitConnected: json['isFitbitConnected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletAddress': walletAddress,
      'name': name,
      'age': age,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'bio': bio,
      'isFitbitConnected': isFitbitConnected,
    };
  }
} 