import 'prediction.dart';
import 'team.dart';

export 'prediction.dart';

enum GameStatus { upcoming, finished }

class Game {
  final String id;
  final Team homeTeam;
  final Team awayTeam;
  final DateTime kickoffTime; // always UTC
  final int? homeScore;
  final int? awayScore;
  final GameStatus status;
  final DateTime? finishedAt; // UTC — set when result is recorded, used for new results popup
  final String round; // raw string from the API e.g. "Matchday 1", "Matchday 8"
  final String ground; // venue name e.g. "Mexico City"

  const Game({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.kickoffTime,
    required this.status,
    this.homeScore,
    this.awayScore,
    this.finishedAt,
    this.round = '',
    this.ground = '',
  });

  bool get isFinished => status == GameStatus.finished;

  /// The actual result of the game. Null until the game is finished.
  /// Scoring engine uses this: guess.prediction == game.outcome → correct.
  Prediction? get outcome {
    if (!isFinished || homeScore == null || awayScore == null) return null;
    if (homeScore! > awayScore!) return Prediction.teamAWins;
    if (awayScore! > homeScore!) return Prediction.teamBWins;
    return Prediction.draw;
  }

  /// Date portion of kickoffTime in UTC.
  /// Used by the scoring engine to group games by day for the set bonus.
  DateTime get matchDay => DateTime.utc(
        kickoffTime.year,
        kickoffTime.month,
        kickoffTime.day,
      );

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] as String,
        homeTeam: Team.fromJson(json['homeTeam'] as Map<String, dynamic>),
        awayTeam: Team.fromJson(json['awayTeam'] as Map<String, dynamic>),
        kickoffTime: DateTime.parse(json['kickoffTime'] as String).toUtc(),
        homeScore: json['homeScore'] as int?,
        awayScore: json['awayScore'] as int?,
        // status may be absent on documents written by the sync (schedule-only
        // merge). Default to upcoming so fromJson never throws on new docs.
        status: json['status'] != null
            ? GameStatus.values.byName(json['status'] as String)
            : GameStatus.upcoming,
        finishedAt: json['finishedAt'] != null
            ? DateTime.parse(json['finishedAt'] as String).toUtc()
            : null,
        round: (json['round'] as String?) ?? '',
        ground: (json['ground'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'homeTeam': homeTeam.toJson(),
        'awayTeam': awayTeam.toJson(),
        'kickoffTime': kickoffTime.toIso8601String(),
        'homeScore': homeScore,
        'awayScore': awayScore,
        'status': status.name,
        'finishedAt': finishedAt?.toIso8601String(),
        'round': round,
        'ground': ground,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Game && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Game($id, ${homeTeam.name} vs ${awayTeam.name})';
}
