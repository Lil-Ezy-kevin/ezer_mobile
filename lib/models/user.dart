class AppUser {
  final int id;
  final String name;
  final String email;
  final String role; // client, prestataire, admin
  final String phone;
  final String city;
  final String service;
  final String bio;
  final bool verified;
  final String photo;
  final String availability;
  final bool active;
  final double avgRating;
  final int reviewCount;
  final int unreadNotifications;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.city = '',
    this.service = '',
    this.bio = '',
    this.verified = false,
    this.photo = '',
    this.availability = 'Disponible',
    this.active = true,
    this.avgRating = 0,
    this.reviewCount = 0,
    this.unreadNotifications = 0,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      phone: json['phone'] ?? '',
      city: json['city'] ?? '',
      service: json['service'] ?? '',
      bio: json['bio'] ?? '',
      verified: (json['verified'] ?? 0) == 1 || json['verified'] == true,
      photo: json['photo'] ?? '',
      availability: json['availability'] ?? 'Disponible',
      active: (json['active'] ?? 1) == 1 || json['active'] == true,
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      unreadNotifications: json['unread_notifications'] ?? 0,
    );
  }
}
