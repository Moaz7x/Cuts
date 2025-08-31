import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/project_model.dart';

/// A service class to handle saving and loading project data to the device's file system.
class ProjectService {
  static const String _fileName = 'flashcut_project.json';

  /// Returns the path to the file where the project is stored.
  static Future<File> _getProjectFile() async {
    // Get the application's private documents directory.
    // This data is backed up and persists between app updates.
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  /// Saves the given [project] data to a local JSON file.
  ///
  /// It serializes the Project object to a JSON string and writes it to the disk.
  static Future<void> saveProject(Project project) async {
    try {
      final file = await _getProjectFile();
      // Use jsonEncode to convert the map from project.toJson() into a string.
      final jsonString = jsonEncode(project.toJson());
      await file.writeAsString(jsonString);
      print("Project saved successfully to ${file.path}");
    } catch (e) {
      print("Error saving project: $e");
    }
  }

  /// Loads project data from the local JSON file.
  ///
  /// Returns a [Project] object if a saved file is found and successfully parsed.
  /// Returns `null` if no project file exists or if an error occurs during reading/parsing.
  static Future<Project?> loadProject() async {
    try {
      final file = await _getProjectFile();

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        // Use jsonDecode to convert the file's string content back into a map.
        final jsonMap = jsonDecode(jsonString);
        print("Project loaded successfully from ${file.path}");
        // Create a Project instance from the map.
        return Project.fromJson(jsonMap);
      }
    } catch (e) {
      print("Error loading project: $e");
    }
    // Return null if the file doesn't exist or if there was an error.
    return null;
  }
}
