import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project_model.dart';
import '../../models/ruler_model.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/image_provider.dart';
import '../../providers/ruler_provider.dart';
import '../../utils/image_cropper_service.dart';
import '../../utils/project_service.dart';
import '../../widgets/draggable_ruler_widget.dart';
import '../editor/editor_screen.dart';

class CroppingScreen extends StatefulWidget {
  const CroppingScreen({super.key});

  @override
  State<CroppingScreen> createState() => _CroppingScreenState();
}

class _CroppingScreenState extends State<CroppingScreen> {
  // Use two keys: one for the image itself, and one for the Stack that contains it.
  final GlobalKey _imageKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // When the screen is first built, clear any old data from providers.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if rulers are already present (e.g., from a loaded project).
      // If not, clear them.
      if (Provider.of<RulerProvider>(context, listen: false).rulers.isEmpty) {
        Provider.of<RulerProvider>(context, listen: false).clearRulers();
      }
      Provider.of<FlashcardProvider>(context, listen: false).clear();
    });
  }

  /// Processes the image with the current ruler positions and navigates to the editor.
  Future<void> _processAndNavigate() async {
    final imageProvider = Provider.of<ImageStateProvider>(context, listen: false);
    final rulerProvider = Provider.of<RulerProvider>(context, listen: false);
    final flashcardProvider = Provider.of<FlashcardProvider>(context, listen: false);

    final imageFile = imageProvider.image;
    if (imageFile == null) return;

    // Get the RenderBox for both the image and its containing Stack.
    final RenderBox? imageRenderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? stackRenderBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (imageRenderBox == null || stackRenderBox == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Could not calculate image layout.")),
        );
      }
      return;
    }

    final displayedImageSize = imageRenderBox.size;

    // Calculate the image's top-left offset relative to the Stack.
    // This gives us the exact padding Flutter adds around the image.
    final imageTopLeftOffset = imageRenderBox.localToGlobal(Offset.zero) - stackRenderBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Pass all the necessary layout information to the service for accurate cropping.
    final croppedImages = await ImageCropperService.cropImageWithRulers(
      imageFile: imageFile,
      rulers: rulerProvider.rulers,
      displayedImageSize: displayedImageSize,
      imageOffset: imageTopLeftOffset,
    );

    flashcardProvider.setCroppedImages(croppedImages);

    if (context.mounted) Navigator.pop(context);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditorScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageStateProvider>(context);
    final rulerProvider = Provider.of<RulerProvider>(context);
    final File? selectedImage = imageProvider.image;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Cuts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: "Save Project",
            onPressed: () async {
              if (imageProvider.image?.path == null) return;
              final project = Project(
                imagePath: imageProvider.image!.path,
                rulers: rulerProvider.rulers,
              );
              await ProjectService.saveProject(project);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Project Saved!")),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Process Cuts",
            onPressed: _processAndNavigate,
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
                      key: _stackKey, // Assign key to the parent Stack
                      fit: StackFit.expand,
                      children: [
                        Center(
                          child: Image.file(
                            selectedImage,
                            key: _imageKey, // Assign key to the Image
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Use a LayoutBuilder to get constraints for the rulers
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
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Add Vertical"),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Clear All Rulers?"),
                        content: const Text("Are you sure you want to remove all rulers?"),
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
