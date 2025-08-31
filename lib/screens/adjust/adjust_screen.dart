import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/image_provider.dart';
import '../../widgets/corner_marker_widget.dart';
import '../cropping/cropping_screen.dart'; // We will navigate here after adjusting

class AdjustScreen extends StatefulWidget {
  const AdjustScreen({super.key});

  @override
  State<AdjustScreen> createState() => _AdjustScreenState();
}

class _AdjustScreenState extends State<AdjustScreen> {
  // A list to hold the positions of the four corner markers
  List<Offset> _cornerPoints = [];
  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // After the first frame is rendered, initialize the corner points
    // to the corners of the image widget.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCornerPoints();
    });
  }

  void _initializeCornerPoints() {
    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    setState(() {
      _cornerPoints = [
        const Offset(50, 50), // Top-left
        Offset(size.width - 50, 50), // Top-right
        Offset(size.width - 50, size.height - 50), // Bottom-right
        Offset(50, size.height - 50), // Bottom-left
      ];
    });
  }

  void _updateCornerPosition(int index, DragUpdateDetails details) {
    setState(() {
      // Update the position of the dragged marker
      _cornerPoints[index] += details.delta;
    });
  }

  void _applyTransformation() {
    // TODO: In the next step, we will call the OpenCV service here.
    // For now, we will just print the points and navigate.
    print("Applying transformation with points: $_cornerPoints");
    
    // After transformation, the new image would be set in the provider,
    // and then we navigate to the cropping screen.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CroppingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageStateProvider>(context);
    final File? selectedImage = imageProvider.currentImage;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Adjust Perspective"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Apply Adjustment",
            onPressed: _applyTransformation,
          ),
        ],
      ),
      body: selectedImage == null
          ? const Center(child: Text("No Image Selected."))
          : Stack(
              fit: StackFit.expand,
              children: [
                // Display the image
                Center(
                  child: Image.file(
                    selectedImage,
                    key: _imageKey,
                    fit: BoxFit.contain,
                  ),
                ),
                // Custom painter to draw lines between markers
                if (_cornerPoints.length == 4)
                  CustomPaint(
                    painter: PolygonPainter(points: _cornerPoints),
                  ),
                // Display the four corner markers
                if (_cornerPoints.length == 4) ...[
                  CornerMarker(
                    position: _cornerPoints[0],
                    onPanUpdate: (details) => _updateCornerPosition(0, details),
                  ),
                  CornerMarker(
                    position: _cornerPoints[1],
                    onPanUpdate: (details) => _updateCornerPosition(1, details),
                  ),
                  CornerMarker(
                    position: _cornerPoints[2],
                    onPanUpdate: (details) => _updateCornerPosition(2, details),
                  ),
                  CornerMarker(
                    position: _cornerPoints[3],
                    onPanUpdate: (details) => _updateCornerPosition(3, details),
                  ),
                ]
              ],
            ),
    );
  }
}

// A simple painter to draw the polygon connecting the corner points.
class PolygonPainter extends CustomPainter {
  final List<Offset> points;

  PolygonPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
