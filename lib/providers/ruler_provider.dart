import 'package:flutter/material.dart';

import '../models/ruler_model.dart';

class RulerProvider with ChangeNotifier {
  final List<Ruler> _rulers = [];
  int _nextId = 0;

  List<Ruler> get rulers => _rulers;

  /// Adds a new ruler of the specified orientation.
  
  void addRuler(RulerOrientation orientation) {
    _rulers.add(Ruler(id: _nextId++, orientation: orientation, position: 100.0));
    notifyListeners();
  }


  /// Updates a ruler's position based on drag details and clamps it within the given constraints.
  void updateRulerPosition(int id, DragUpdateDetails details, BoxConstraints constraints) {
    try {
      final ruler = _rulers.firstWhere((r) => r.id == id);
      if (ruler.orientation == RulerOrientation.horizontal) {
        // Calculate the new vertical position and clamp it between 0 and the max height.
        final newPosition = ruler.position + details.delta.dy;
        ruler.position = newPosition.clamp(0.0, constraints.maxHeight);
      } else {
        // Calculate the new horizontal position and clamp it between 0 and the max width.
        final newPosition = ruler.position + details.delta.dx;
        ruler.position = newPosition.clamp(0.0, constraints.maxWidth);
      }
      notifyListeners();
    } catch (e) {
      // This can happen if the ruler is removed while being dragged. Safe to ignore.
      print("Error updating ruler position: $e");
    }
  }
// NEW: Method to remove a specific ruler by its ID
  void removeRuler(int id) {
    _rulers.removeWhere((ruler) => ruler.id == id);
    notifyListeners();
  }
  /// Removes all rulers from the list.
  void clearRulers() {
    _rulers.clear();
    notifyListeners();
  }
}
