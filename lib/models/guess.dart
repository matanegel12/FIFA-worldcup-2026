import 'prediction.dart';

export 'prediction.dart';

class Guess {
  final String userId;
  final String gameId;
  final Prediction prediction;
  final DateTime createdAt; // UTC — set once on submission, used as secondary tiebreaker

  const Guess({
    required this.userId,
    required this.gameId,
    required this.prediction,
    required this.createdAt,
  });

  /// Builds the Firestore document ID for this guess.
  /// Enforces one guess per user per game at the database level.
  static String compoundId(String userId, String gameId) => '${userId}_$gameId';

  factory Guess.fromJson(Map<String, dynamic> json) => Guess(
        userId: json['userId'] as String,
        gameId: json['gameId'] as String,
        prediction: Prediction.values.byName(json['prediction'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'gameId': gameId,
        'prediction': prediction.name,
        'createdAt': createdAt.toIso8601String(),
      };

  // createdAt is intentionally excluded — it is set once on creation and never changed.
  Guess copyWith({Prediction? prediction}) => Guess(
        userId: userId,
        gameId: gameId,
        prediction: prediction ?? this.prediction,
        createdAt: createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Guess && other.userId == userId && other.gameId == gameId);

  @override
  int get hashCode => Object.hash(userId, gameId);

  @override
  String toString() => 'Guess($userId, $gameId, ${prediction.name})';
}
