enum RulerOrientation { horizontal, vertical }

class Ruler {
  final int id;
  final RulerOrientation orientation;
  double position; // The position (offset) from the top or left

  Ruler({
    required this.id,
    required this.orientation,
    this.position = 100.0, // Default position
  });
}
