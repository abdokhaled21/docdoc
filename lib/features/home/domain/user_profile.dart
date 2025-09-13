class UserProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String gender;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
  });

  factory UserProfile.fromApi(Map<String, dynamic> json) {
    return UserProfile(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
    );
  }
}
