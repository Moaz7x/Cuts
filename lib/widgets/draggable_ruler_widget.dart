import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ruler_model.dart';
import '../providers/ruler_provider.dart';

class DraggableRuler extends StatelessWidget {
  final Ruler ruler;
  final BoxConstraints constraints;

  const DraggableRuler({
    super.key,
    required this.ruler,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final rulerProvider = Provider.of<RulerProvider>(context, listen: false);
    final bool isHorizontal = ruler.orientation == RulerOrientation.horizontal;

    // The main interactive handle for dragging and deleting.
    final Widget handle = SizedBox(
      width: isHorizontal ? 60 : 40,
      height: isHorizontal ? 40 : 60,
      child: Material(
        color: Colors.blue.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Drag icon in the center
            Icon(
              isHorizontal ? Icons.drag_handle : Icons.drag_indicator,
              color: Colors.white,
              size: 24,
            ),
            // Delete button in the top right of the handle
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // Show a confirmation dialog before deleting
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Ruler?'),
                      content: const Text('Are you sure you want to delete this ruler?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        TextButton(
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            rulerProvider.removeRuler(ruler.id);
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // The thin line that extends across the screen.
    final Widget line = Container(
      width: isHorizontal ? constraints.maxWidth : 2,
      height: isHorizontal ? 2 : constraints.maxHeight,
      color: Colors.blue.withOpacity(0.7),
    );

    // Use a Stack to position the handle and the line.
    return Positioned(
      top: isHorizontal ? ruler.position - 20 : 0, // Center handle vertically
      left: isHorizontal ? 0 : ruler.position - 20, // Center handle horizontally
      child: GestureDetector(
        onPanUpdate: (details) {
          rulerProvider.updateRulerPosition(ruler.id, details, constraints);
        },
        child: SizedBox(
          width: isHorizontal ? constraints.maxWidth : 40,
          height: isHorizontal ? 40 : constraints.maxHeight,
          child: Stack(
            children: [
              // Position the line
              Positioned(
                top: isHorizontal ? 19 : 0, // Center line vertically
                left: isHorizontal ? 0 : 19, // Center line horizontally
                child: line,
              ),
              // Position the handle
              Positioned(
                top: 0,
                left: 0,
                child: handle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
