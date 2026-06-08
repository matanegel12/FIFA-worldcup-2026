import 'package:flutter/material.dart';

/// Displays a team's flag loaded from a URL.
/// Default size is 48×32 (large card use). Pass [width] and [height]
/// for smaller inline variants.
class TeamFlag extends StatelessWidget {
  final String flagUrl;
  final double width;
  final double height;

  const TeamFlag({
    required this.flagUrl,
    this.width = 48,
    this.height = 32,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        flagUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: height >= 24
              ? Icon(Icons.flag, size: 14, color: Colors.grey.shade400)
              : null,
        ),
      ),
    );
  }
}
