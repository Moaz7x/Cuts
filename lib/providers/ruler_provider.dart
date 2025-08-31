import 'package:flutter/material.dart';
import '../models/ruler_model.dart';

/// This provider manages the state of the rulers on the cropping screen.
class RulerProvider with ChangeNotifier {
  final List<Ruler> _rulers = [];
  int _nextId = 0;

  List<Ruler> get rulers => _rulers;

  /// Adds a new ruler of the specified orientation to the screen.
  void addRuler(RulerOrientation orientation) {
    _rulers.add(Ruler(id: _nextId++, orientation: orientation, position: 100.0));
    notifyListeners();
  }

  /// Removes a specific ruler by its unique ID.
  void removeRuler(int id) {
    _rulers.removeWhere((ruler) => ruler.id == id);
    notifyListeners();
  }

  /// Updates the position of a ruler as it's being dragged.
  void updateRulerPosition(int id, DragUpdateDetails details, BoxConstraints constraints) {
    final ruler = _rulers.firstWhere((r) => r.id == id);
    if (ruler.orientation == RulerOrientation.horizontal) {
      final newPosition = ruler.position + details.delta.dy;
      // Constrain the ruler to stay within the vertical bounds of the container.
      if (newPosition >= 0 && newPosition <= constraints.maxHeight) {
        ruler.position = newPosition;
      }
    } else {
      final newPosition = ruler.position + details.delta.dx;
      // Constrain the ruler to stay within the horizontal bounds of the container.
      if (newPosition >= 0 && newPosition <= constraints.maxWidth) {
        ruler.position = newPosition;
      }
    }
    notifyListeners();
  }

  /// Removes all rulers from the screen.
  void clearRulers() {
    _rulers.clear();
    _nextId = 0;
    notifyListeners();
  }

  /// **NEW:** Replaces the current list of rulers with a new list from a loaded project.
  ///
  /// This is essential for the "Load Project" functionality.
  void setRulers(List<Ruler> loadedRulers) {
    _rulers.clear();
    _rulers.addAll(loadedRulers);

    // Ensure the next ID for any new rulers doesn't conflict with the loaded ones.
    if (loadedRulers.isNotEmpty) {
      // Find the highest ID among the loaded rulers and set the next ID to be one greater.
      _nextId = loadedRulers.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;
    } else {
      _nextId = 0;
    }

    notifyListeners();
  }
}
