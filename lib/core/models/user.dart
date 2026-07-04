class User {
  String id;
  String name;
  String email;
  int? age;
  String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.age = 0,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age ?? 0,
      'profile_image': profileImage,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] as int? ?? 0,
      profileImage: map['profile_image']?.toString(),
    );
  }
}
