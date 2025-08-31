import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/image_provider.dart';
import 'providers/ruler_provider.dart'; // Import the new provider
import 'screens/home/home_screen.dart';
import 'providers/flashcard_provider.dart'; // Import the new provider

void main() {
  runApp(
    // Use MultiProvider to combine multiple providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ImageStateProvider()),
        ChangeNotifierProvider(create: (context) => RulerProvider()),
                ChangeNotifierProvider(create: (context) => FlashcardProvider()), // Add this line

      ],
      child: const FlashCutApp(),
    ),
  );
}

class FlashCutApp extends StatelessWidget {
  const FlashCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashCut - Smart Flashcard Creator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}
