import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Cup 2026 Predictions',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3A5C)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('World Cup 2026'),
        ),
      ),
    );
  }
}
