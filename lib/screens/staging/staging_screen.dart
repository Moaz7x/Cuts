import 'dart:io';

import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/flashcard_provider.dart';
import '../../providers/image_provider.dart';
import '../../providers/ruler_provider.dart';
import '../cropping/cropping_screen.dart';

class StagingScreen extends StatelessWidget {
  const StagingScreen({super.key});

  /// Handles the adjustment of a single image using the document scanner.
  Future<void> _adjustImage(BuildContext context, int index) async {
    final imageProvider = Provider.of<ImageStateProvider>(context, listen: false);

    final source = await showModalBottomSheet<ScannerFileSource>(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Re-scan with Camera'),
                onTap: () => Navigator.pop(context, ScannerFileSource.CAMERA),
              ),
              ListTile(
                leading: const Icon(Icons.image_search),
                title: const Text('Re-select from Gallery'),
                onTap: () => Navigator.pop(context, ScannerFileSource.GALLERY),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return; // User cancelled the selection

    try {
      File? adjustedImage = await DocumentScannerFlutter.launch(
        context,
        source: source,
        labelsConfig: {
          ScannerLabelsConfig.ANDROID_OK_LABEL: "Confirm Adjustment",
          ScannerLabelsConfig.ANDROID_CANT_CROP_ERROR_TITLE: "Adjust Image ${index + 1}",
        },
      );

      if (adjustedImage != null) {
        imageProvider.replaceImageAtIndex(index, adjustedImage);
      }
    } catch (e) {
      print("Error during adjustment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageStateProvider>(
      builder: (context, imageProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Image Batch (${imageProvider.imageList.length})'),
            actions: [
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                tooltip: "Start Cutting Process",
                // Disable the button if there are no images in the batch.
                onPressed: imageProvider.imageList.isEmpty
                    ? null
                    : () {
                        // Clear any flashcards from a previous batch.
                        Provider.of<FlashcardProvider>(context, listen: false).clear();

                        // Set the first image as the current one for editing.
                        imageProvider.setCurrentIndex(0);
                        Provider.of<RulerProvider>(context, listen: false).clearRulers();

                        // Navigate to the cropping screen to begin.
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CroppingScreen()),
                        );
                      },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: imageProvider.imageList.length,
              itemBuilder: (context, index) {
                final imageFile = imageProvider.imageList[index];
                return GestureDetector(
                  onTap: () => _adjustImage(context, index),
                  child: GridTile(
                    header: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                    footer: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: Text(
                        'Image ${index + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(imageFile, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
