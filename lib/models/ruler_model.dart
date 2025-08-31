/// Enum to define whether a ruler is horizontal or vertical.
enum RulerOrientation { horizontal, vertical }

/// A data class that represents a single draggable ruler on the screen.
class Ruler {
  final int id;
  final RulerOrientation orientation;
  double position;

  Ruler({required this.id, required this.orientation, this.position = 100.0});

  /// **NEW:** Converts this Ruler instance into a JSON-encodable map.
  /// This is required by the Project model for saving.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Enums are saved as strings (e.g., 'horizontal') for readability.
      'orientation': orientation.toString().split('.').last,
      'position': position,
    };
  }

  /// **NEW:** Creates a Ruler instance from a JSON map.
  /// This factory constructor is required by the Project model for loading.
  factory Ruler.fromJson(Map<String, dynamic> json) {
    return Ruler(
      id: json['id'],
      // The string from the JSON is converted back into its corresponding enum value.
      orientation: RulerOrientation.values.firstWhere(
        (e) => e.toString().split('.').last == json['orientation'],
        orElse: () => RulerOrientation.horizontal, // Default fallback
      ),
      position: json['position'],
    );
  }
}
