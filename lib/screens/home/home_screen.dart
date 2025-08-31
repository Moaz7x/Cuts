import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../providers/image_provider.dart';
import '../../providers/ruler_provider.dart';
import '../../utils/project_service.dart';
import '../cropping/cropping_screen.dart';
import '../staging/staging_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Handles selecting multiple images from the gallery.
  /// It first requests the necessary permissions before opening the image picker.
 Future<void> _selectAndStageImages(BuildContext context) async {
    PermissionStatus status;

    // THE FIX: Check the platform and SDK version to request the correct permission.
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        // For Android 12 and lower, use the general storage permission.
        status = await Permission.storage.request();
      } else {
        // For Android 13 and higher, use the more specific photos permission.
        status = await Permission.photos.request();
      }
    } else {
      // For iOS and other platforms, 'photos' is the correct permission.
      status = await Permission.photos.request();
    }

    // The rest of the logic remains the same, handling the 'status' variable.
    if (status.isGranted) {
      final imageProvider = Provider.of<ImageStateProvider>(context, listen: false);
      imageProvider.clearAll();
      await imageProvider.pickMultipleImages();

      if (imageProvider.imageList.isNotEmpty && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StagingScreen()),
        );
      }
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission permanently denied. Please enable it in app settings.")),
        );
        openAppSettings();
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission is required to select images.")),
        );
      }
    }
  }
  /// Loads the last saved project from a local file.
  Future<void> _loadProject(BuildContext context) async {
    final project = await ProjectService.loadProject();

    if (project != null && context.mounted) {
      // Get providers to update their state.
      final imageProvider = Provider.of<ImageStateProvider>(context, listen: false);
      final rulerProvider = Provider.of<RulerProvider>(context, listen: false);

      // Update state with loaded data.
      // Use the single-image batch method for the loaded project's image.
      imageProvider.startNewBatchWithSingleImage(File(project.imagePath));
      rulerProvider.setRulers(project.rulers);

      // Navigate directly to the cropping screen with the project restored.
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CroppingScreen()));
    } else if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No saved project found.")));
    }
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
                'Create Your Flashcards',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Select multiple images to start a new batch.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: () => _selectAndStageImages(context),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Select Images'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: () => _loadProject(context),
                icon: const Icon(Icons.folder_open),
                label: const Text('Load Last Project'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
