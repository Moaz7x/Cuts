import 'package:cuts/screens/editor/editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/image_provider.dart';
import '../../providers/ruler_provider.dart';
import '../cropping/cropping_screen.dart';

class StagingScreen extends StatelessWidget {
  const StagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageStateProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Image Batch (${imageProvider.imageList.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Proceed to Final Edit",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditorScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 images per row
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: imageProvider.imageList.length,
          itemBuilder: (context, index) {
            final imageFile = imageProvider.imageList[index];
            return GestureDetector(
              onTap: () {
                // Set the tapped image as the current one for editing.
                imageProvider.setCurrentIndex(index);
                // Clear any rulers from a previous edit.
                Provider.of<RulerProvider>(context, listen: false).clearRulers();
                // Navigate to the cropping screen.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CroppingScreen()),
                );
              },
              child: GridTile(
                footer: Container(
                  padding: const EdgeInsets.all(4),
                  color: Colors.black.withOpacity(0.5),
                  child: Text(
                    'Image ${index + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                child: Image.file(imageFile, fit: BoxFit.cover),
              ),
            );
          },
        ),
      ),
    );
  }
}
