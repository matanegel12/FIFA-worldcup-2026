class Team {
  final String fifaCode;
  final String isoCode;
  final String name;

  const Team({
    required this.fifaCode,
    required this.isoCode,
    required this.name,
  });

  /// Flag image URL using the 2-letter ISO code.
  /// Widgets should read this getter instead of building the URL themselves.
  String get flagUrl => 'https://flagcdn.com/w80/$isoCode.png';

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        fifaCode: json['fifaCode'] as String,
        isoCode: json['isoCode'] as String,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'fifaCode': fifaCode,
        'isoCode': isoCode,
        'name': name,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Team && other.fifaCode == fifaCode);

  @override
  int get hashCode => fifaCode.hashCode;

  @override
  String toString() => 'Team($fifaCode, $name)';
}
