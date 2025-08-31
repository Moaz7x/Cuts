import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/image_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/ruler_provider.dart';
import '../cropping/cropping_screen.dart';
// We will create this widget next
import 'widgets/adjustment_canvas_widget.dart'; 

class ContactSheetScreen extends StatelessWidget {
  const ContactSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageStateProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prepare Your Images"),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: "Next: Add Cuts",
            onPressed: imageProvider.imageList.isEmpty ? null : () {
              // This button will take the adjusted batch to the cropping workflow
              Provider.of<FlashcardProvider>(context, listen: false).clear();
              imageProvider.setCurrentIndex(0);
              Provider.of<RulerProvider>(context, listen: false).clearRulers();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CroppingScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. THE CANVAS (Top 60% of the screen)
          // This will contain the large image and the adjustment handles.
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.black87,
              child: imageProvider.currentImage != null
                  ? AdjustmentCanvas() // We will build this powerful widget
                  : const Center(
                      child: Text(
                        "Add images to begin",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
            ),
          ),

          // 2. THE FILMSTRIP (Bottom 40% of the screen)
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.grey[200],
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Your Project Filmstrip",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(10),
                      itemCount: imageProvider.imageList.length + 1, // +1 for the "Add" button
                      itemBuilder: (context, index) {
                        // The last item is always the "Add Images" button
                        if (index == imageProvider.imageList.length) {
                          return _buildAddImagesButton(context);
                        }

                        final imageFile = imageProvider.imageList[index];
                        final isSelected = index == imageProvider.currentIndex;

                        return GestureDetector(
                          onTap: () => imageProvider.setCurrentIndex(index),
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey,
                                width: isSelected ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(imageFile, fit: BoxFit.cover),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the "Add Images" button in the filmstrip
  Widget _buildAddImagesButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // We will reuse the permission logic from the home screen
        final imageProvider = Provider.of<ImageStateProvider>(context, listen: false);
        await imageProvider.pickMultipleImages(addToExisting: true);
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey, style: BorderStyle.solid),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined),
              SizedBox(height: 5),
              Text("Add Images", textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
