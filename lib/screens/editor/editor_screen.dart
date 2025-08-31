import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/flutter_reorderable_grid_view.dart';
import 'package:provider/provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../utils/pdf_exporter_service.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  Widget build(BuildContext context) {
    // Access the provider to get the list of cropped images and listen for changes.
    final flashcardProvider = Provider.of<FlashcardProvider>(context);
    final croppedImages = flashcardProvider.croppedImages;

    // Manually create the list of widgets for the `children` property.
    final List<Widget> flashcardWidgets = croppedImages.map((item) {
      // Use a Card for a nice visual effect and provide a unique key.
      // The ValueKey is crucial for the reordering logic to identify which widget is which.
      return Card(
        key: ValueKey(item.id),
        clipBehavior: Clip.antiAlias, // Ensures the image respects the card's rounded corners.
        child: GridTile(
          child: Image.memory(
            item.imageBytes,
            fit: BoxFit.cover,
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Arrange Flashcards"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: "Export as PDF",
            onPressed: () {
              if (croppedImages.isNotEmpty) {
                // Call the exporter service with the (potentially reordered) list of images.
                PdfExporterService.exportToPdf(images: croppedImages);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("There are no flashcards to export.")),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        // Use the default ReorderableGridView constructor.
        child: ReorderableGridView(
          // Define the grid layout: 2 columns with spacing.
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1, // Makes the cells square.
          ),
          // Pass the pre-built list of widgets.
          children: flashcardWidgets,
          // The callback is triggered when an item is dragged and dropped.
          onReorder: (oldIndex, newIndex) {
            // Call the provider to handle the reordering logic and update the state.
            flashcardProvider.reorderFlashcards(oldIndex, newIndex);
          },
        ),
      ),
    );
  }
}
