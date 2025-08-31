import 'dart:io';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
import '../../providers/image_provider.dart';
import '../cropping/cropping_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// This method now handles permissions before opening the document scanner.
  Future<void> _scanDocument(BuildContext context, ScannerFileSource source) async {
    // 1. Request permissions
    // We request both camera and photos, as the user can choose either source.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos, // Use .photos for modern cross-platform compatibility
    ].request();

    // Check if permissions were granted
    bool isCameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    bool isPhotosGranted = statuses[Permission.photos]?.isGranted ?? false;

    // The scanner needs the specific permission for the source it's opening.
    if ((source == ScannerFileSource.CAMERA && !isCameraGranted) ||
        (source == ScannerFileSource.GALLERY && !isPhotosGranted)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission required to access the scanner.")),
        );
      }
      return;
    }

    // 2. If permissions are granted, proceed to launch the scanner.
    final imageProvider = Provider.of<ImageStateProvider>(context, listen: false);
    try {
      File? scannedImage = await DocumentScannerFlutter.launch(
        context,
        source: source, // Use the source passed to the function
        labelsConfig: {
          ScannerLabelsConfig.ANDROID_NEXT_BUTTON_LABEL: "Next",
          ScannerLabelsConfig.ANDROID_OK_LABEL: "OK",
        },
      );

      if (scannedImage != null && context.mounted) {
        imageProvider.setImage(scannedImage);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CroppingScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error launching document scanner: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scanner failed. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashCut Creator'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ... (Icon and Text widgets remain the same)
              const SizedBox(height: 50),
              // Button for Camera
              ElevatedButton.icon(
                onPressed: () => _scanDocument(context, ScannerFileSource.CAMERA),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Scan with Camera'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              // Button for Gallery
              ElevatedButton.icon(
                onPressed: () => _scanDocument(context, ScannerFileSource.GALLERY),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Import from Gallery'),
                style: ElevatedButton.styleFrom(
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
