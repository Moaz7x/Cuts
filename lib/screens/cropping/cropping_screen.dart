import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ruler_model.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/image_provider.dart';
import '../../providers/ruler_provider.dart';
import '../../utils/image_cropper_service.dart';
import '../../widgets/draggable_ruler_widget.dart';
import '../editor/editor_screen.dart';

class CroppingScreen extends StatefulWidget {
  const CroppingScreen({super.key});

  @override
  State<CroppingScreen> createState() => _CroppingScreenState();
}

class _CroppingScreenState extends State<CroppingScreen> {
  final GlobalKey _imageKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();

  /// Processes only the currently active image.
  Future<void> _processCurrentImage() async {
    final imageProvider = Provider.of<ImageStateProvider>(context, listen: false);
    final rulerProvider = Provider.of<RulerProvider>(context, listen: false);
    final flashcardProvider = Provider.of<FlashcardProvider>(context, listen: false);

    final imageFile = imageProvider.currentImage;
    if (imageFile == null) return;

    final RenderBox? imageRenderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? stackRenderBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (imageRenderBox == null || stackRenderBox == null) return;

    final displayedImageSize = imageRenderBox.size;
    final imageTopLeftOffset = imageRenderBox.localToGlobal(Offset.zero) - stackRenderBox.localToGlobal(Offset.zero);

    final croppedImages = await ImageCropperService.cropImageWithRulers(
      imageFile: imageFile,
      rulers: rulerProvider.rulers,
      displayedImageSize: displayedImageSize,
      imageOffset: imageTopLeftOffset,
      // THE FIX: Provide the starting ID based on the number of existing flashcards.
      startingId: flashcardProvider.croppedImages.length,
    );

    flashcardProvider.addCroppedImages(croppedImages);
  }

  /// Main action method: handles dialogs, processes the image, and advances the workflow.
  Future<void> _processAndAdvance() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await _processCurrentImage();

    if (context.mounted) Navigator.pop(context);

    final imageProvider = Provider.of<ImageStateProvider>(context, listen: false);
    final rulerProvider = Provider.of<RulerProvider>(context, listen: false);

    if (imageProvider.currentIndex < imageProvider.imageList.length - 1) {
      imageProvider.setCurrentIndex(imageProvider.currentIndex + 1);
      rulerProvider.clearRulers();
    } else {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EditorScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageStateProvider>(context);
    final rulerProvider = Provider.of<RulerProvider>(context);
    final File? selectedImage = imageProvider.currentImage;

    return Scaffold(
      appBar: AppBar(
        title: Text("Cutting Image ${imageProvider.currentIndex + 1} of ${imageProvider.imageList.length}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Confirm Cuts & Next Image",
            onPressed: _processAndAdvance,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: selectedImage == null
                  ? const Center(child: Text("No Image Selected."))
                  : Stack(
                      key: _stackKey,
                      fit: StackFit.expand,
                      children: [
                        Center(
                          child: Image.file(
                            selectedImage,
                            key: _imageKey,
                            fit: BoxFit.contain,
                          ),
                        ),
                        LayoutBuilder(builder: (context, constraints) {
                          return Stack(
                            children: [
                              ...rulerProvider.rulers.map((ruler) {
                                return DraggableRuler(ruler: ruler, constraints: constraints);
                              }).toList(),
                            ],
                          );
                        }),
                      ],
                    ),
            ),
          ),
          Container(
            height: 100,
            color: Colors.blueGrey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => rulerProvider.addRuler(RulerOrientation.horizontal),
                  icon: const Icon(Icons.horizontal_rule),
                  label: const Text("Add Horizontal"),
                ),
                ElevatedButton.icon(
                  onPressed: () => rulerProvider.addRuler(RulerOrientation.vertical),
                  icon: const Icon(Icons.place),
                  label: const Text("Add Vertical"),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Clear All Rulers?"),
                        content: const Text("Are you sure you want to remove all rulers from this image?"),
                        actions: [
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          TextButton(
                            child: const Text("Clear", style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              rulerProvider.clearRulers();
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: "Clear All Rulers",
                  color: Colors.red,
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
