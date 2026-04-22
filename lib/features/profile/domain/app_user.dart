class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final String bio;
  final double averageRating;
  final int totalRentals;

  AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl = '',
    this.bio = '',
    this.averageRating = 0.0,
    this.totalRentals = 0,
  });

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      bio: data['bio'] ?? '',
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRentals: (data['totalRentals'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'averageRating': averageRating,
      'totalRentals': totalRentals,
    };
  }

  AppUser copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    String? bio,
    double? averageRating,
    int? totalRentals,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      averageRating: averageRating ?? this.averageRating,
      totalRentals: totalRentals ?? this.totalRentals,
    );
  }
}
