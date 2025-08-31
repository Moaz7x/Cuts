import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/image_provider.dart';
import '../../../utils/image_adjust_service.dart';

class AdjustmentCanvas extends StatefulWidget {
  const AdjustmentCanvas({super.key});

  @override
  State<AdjustmentCanvas> createState() => _AdjustmentCanvasState();
}

class _AdjustmentCanvasState extends State<AdjustmentCanvas> {
  List<Offset> _cornerHandles = [];
  bool _isProcessing = false;
  Key? _imageObjectKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final imageProvider = Provider.of<ImageStateProvider>(context);
    final currentImage = imageProvider.currentImage;

    // When the image being displayed changes, we must reset the handles.
    if (currentImage != null && Key(currentImage.path) != _imageObjectKey) {
      _imageObjectKey = Key(currentImage.path);
      // We wait for the widget tree to build before initializing the handles,
      // so we can get the final rendered size of the canvas.
      WidgetsBinding.instance.addPostFrameCallback((_) => _initializeHandles());
    }
  }

  /// Calculates the actual bounds of the image as it is rendered on the screen.
  /// This accounts for the padding added by BoxFit.contain.
  Future<Rect?> _calculateImageBounds() async {
    final RenderBox? canvasBox = context.findRenderObject() as RenderBox?;
    final imageProvider = Provider.of<ImageStateProvider>(context, listen: false);
    final currentImage = imageProvider.currentImage;

    if (canvasBox == null || currentImage == null) return null;

    final decodedImage = await decodeImageFromList(currentImage.readAsBytesSync());
    final imagePixelSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());

    final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain, imagePixelSize, canvasBox.size);
    return Alignment.center.inscribe(
      fittedSizes.destination,
      Rect.fromLTWH(0, 0, canvasBox.size.width, canvasBox.size.height),
    );
  }

  /// Initializes the handles to be perfectly at the corners of the displayed image.
  void _initializeHandles() async {
    final Rect? imageBounds = await _calculateImageBounds();
    if (imageBounds == null) return;

    const double inset = 15.0;

    setState(() {
      _cornerHandles = [
        Offset(imageBounds.left + inset, imageBounds.top + inset), // Top-Left
        Offset(imageBounds.right - inset, imageBounds.top + inset), // Top-Right
        Offset(imageBounds.left + inset, imageBounds.bottom - inset), // Bottom-Left
        Offset(imageBounds.right - inset, imageBounds.bottom - inset), // Bottom-Right
      ];
    });
  }

  /// Confirms the adjustment, translates coordinates, and calls the image service.
  Future<void> _onConfirmAdjustment() async {
    setState(() => _isProcessing = true);

    final imageProvider = Provider.of<ImageStateProvider>(context, listen: false);
    final originalImageFile = imageProvider.currentImage;
    final Rect? imageBounds = await _calculateImageBounds();

    if (originalImageFile == null || imageBounds == null) {
      setState(() => _isProcessing = false);
      return;
    }

    final decodedImage = await decodeImageFromList(originalImageFile.readAsBytesSync());
    final imagePixelSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());

    // Calculate the scaling factor between the on-screen image size and the actual pixel size.
    final double scaleX = imagePixelSize.width / imageBounds.width;
    final double scaleY = imagePixelSize.height / imageBounds.height;

    // Translate the handle positions from canvas coordinates to image-relative pixel coordinates.
    final List<Offset> scaledCorners = _cornerHandles.map((handle) {
      final Offset handleRelativeToImage = handle - imageBounds.topLeft;
      return Offset(handleRelativeToImage.dx * scaleX, handleRelativeToImage.dy * scaleY);
    }).toList();

    // Call the service with the correctly translated and scaled corner points.
    final File? adjustedFile = await ImageAdjustService.adjustPerspective(
      originalImageFile,
      scaledCorners,
    );

    if (adjustedFile != null && context.mounted) {
      imageProvider.replaceImageAtIndex(imageProvider.currentIndex, adjustedFile);
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageStateProvider>(context);
    final currentImage = imageProvider.currentImage;

    return Stack(
      fit: StackFit.expand,
      children: [
        // The main image display, visually correct for the user.
        if (currentImage != null) Center(child: Image.file(currentImage, fit: BoxFit.cover)),

        // The painter for the lines connecting the handles.
        if (_cornerHandles.length == 4) CustomPaint(painter: LinePainter(points: _cornerHandles)),

        // The draggable corner handles.
        if (_cornerHandles.length == 4)
          Stack(
            children: List.generate(4, (index) {
              return Positioned(
                left: _cornerHandles[index].dx - 15,
                top: _cornerHandles[index].dy - 15,
                child: Draggable<int>(
                  data: index,
                  feedback: _buildHandle(),
                  child: _buildHandle(),
                  onDragUpdate: (details) {
                    setState(() {
                      _cornerHandles[index] = _cornerHandles[index] + details.delta;
                    });
                  },
                ),
              );
            }),
          ),

        // The "Confirm" button, always visible at the bottom.
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _onConfirmAdjustment,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check),
              label: Text(_isProcessing ? "Processing..." : "Confirm Adjustment"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper method to build the visual for a corner handle.
  Widget _buildHandle() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

/// A custom painter to draw lines connecting the four corner handles.
class LinePainter extends CustomPainter {
  final List<Offset> points;

  LinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length != 4) return;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(points[0].dx, points[0].dy) // Top-Left
      ..lineTo(points[1].dx, points[1].dy) // Top-Right
      ..lineTo(points[3].dx, points[3].dy) // Bottom-Right
      ..lineTo(points[2].dx, points[2].dy) // Bottom-Left
      ..close(); // Back to Top-Left

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
