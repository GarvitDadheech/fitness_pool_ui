class User {
  final String id;
  final String walletAddress;
  final String name;
  final String gender;
  final DateTime dateOfBirth;
  final String bio;
  final bool isFitbitConnected;

  User({
    required this.id,
    required this.walletAddress,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.bio,
    this.isFitbitConnected = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      walletAddress: json['walletAddress'],
      name: json['name'],
      gender: json['gender'] ?? 'Male',
      dateOfBirth: DateTime.parse(json['dob'] ?? json['dateOfBirth']),
      bio: json['bio'],
      isFitbitConnected: json['isFitbitConnected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletAddress': walletAddress,
      'name': name,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'bio': bio,
      'isFitbitConnected': isFitbitConnected,
    };
  }
} 