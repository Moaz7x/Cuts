import 'package:flutter/material.dart';

class CornerMarker extends StatelessWidget {
  final Offset position;
  final Function(DragUpdateDetails) onPanUpdate;

  const CornerMarker({
    super.key,
    required this.position,
    required this.onPanUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // Position the marker on the screen
    return Positioned(
      top: position.dy - 15, // Center the marker on the position
      left: position.dx - 15,
      child: GestureDetector(
        onPanUpdate: onPanUpdate,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.5),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.control_camera, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
