import 'ruler_model.dart';

/// Represents a single saved project.
///
/// Contains all the necessary data to restore the state of the cropping screen,
/// including the path to the base image and the list of user-placed rulers.
class Project {
  final String imagePath;
  final List<Ruler> rulers;

  Project({required this.imagePath, required this.rulers});

  /// Converts this Project instance into a JSON-encodable map.
  ///
  /// This method is used before writing the project data to a file. It iterates
  /// through the rulers and calls their respective `toJson` methods.
  Map<String, dynamic> toJson() {
    return {'imagePath': imagePath, 'rulers': rulers.map((ruler) => ruler.toJson()).toList()};
  }

  /// Creates a Project instance from a JSON map.
  ///
  /// This factory constructor is used after reading the project data from a file.
  /// It parses the map and reconstructs the list of Ruler objects.
  factory Project.fromJson(Map<String, dynamic> json) {
    // Safely cast the 'rulers' list from the JSON.
    var rulerList = json['rulers'] as List;
    // Map each item in the list to a Ruler object using its own fromJson factory.
    List<Ruler> rulers = rulerList.map((i) => Ruler.fromJson(i)).toList();

    return Project(imagePath: json['imagePath'], rulers: rulers);
  }
}
