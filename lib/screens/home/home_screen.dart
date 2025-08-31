import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/image_provider.dart';
import '../contact_sheet/contact_sheet_screen.dart'; // Import our new screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Clears any previous project and navigates to the new ContactSheetScreen.
  void _startNewProject(BuildContext context) {
    // Clear any images from a previous session.
    Provider.of<ImageStateProvider>(context, listen: false).clearAll();

    // Navigate to the new, all-in-one screen.
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactSheetScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlashCut Creator'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(Icons.photo_album_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'Flashcard Studio',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Create a new project to select and adjust your images all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: () => _startNewProject(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create New Project'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              // We can hide the "Load Project" button for now to simplify the UI,
              // as the new workflow is the primary focus.
            ],
          ),
        ),
      ),
    );
  }
}
