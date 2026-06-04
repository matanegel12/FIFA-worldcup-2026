class User {
  final String id; // Firebase Auth UID, matches Firestore document ID
  final String email;
  final String displayName;
  final int totalPoints;
  final DateTime? lastVisitedAt;   // UTC — null on first login, used for new results popup
  final DateTime? scoreReachedAt;  // UTC — null until first point, primary leaderboard tiebreaker

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.totalPoints,
    this.lastVisitedAt,
    this.scoreReachedAt,
  });

  /// Only one admin. Computed from email — never stored in Firestore.
  bool get isAdmin => email == 'matan.egel@remepy.com';

  /// Firestore does not store the document ID inside the document body.
  /// Repositories pass doc.id separately when constructing a User.
  factory User.fromJson(String id, Map<String, dynamic> json) => User(
        id: id,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        totalPoints: (json['totalPoints'] as num).toInt(),
        lastVisitedAt: json['lastVisitedAt'] != null
            ? DateTime.parse(json['lastVisitedAt'] as String).toUtc()
            : null,
        scoreReachedAt: json['scoreReachedAt'] != null
            ? DateTime.parse(json['scoreReachedAt'] as String).toUtc()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'displayName': displayName,
        'totalPoints': totalPoints,
        'lastVisitedAt': lastVisitedAt?.toIso8601String(),
        'scoreReachedAt': scoreReachedAt?.toIso8601String(),
      };

  User copyWith({
    String? displayName,
    int? totalPoints,
    DateTime? lastVisitedAt,
    DateTime? scoreReachedAt,
  }) =>
      User(
        id: id,
        email: email,
        displayName: displayName ?? this.displayName,
        totalPoints: totalPoints ?? this.totalPoints,
        lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
        scoreReachedAt: scoreReachedAt ?? this.scoreReachedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is User && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User($id, $email)';
}
