import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// This provider manages the state of the primary image being worked on.
/// It holds the image file and provides methods to update it.
class ImageStateProvider with ChangeNotifier {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  /// The current image file. Widgets can listen to this to get the image.
  File? get image => _image;

  /// Sets the provider's image directly from a [File] object.
  ///
  /// This is the new method we use after the document scanner
  /// provides us with a processed image file.
  void setImage(File newImage) {
    _image = newImage;
    // Notify all listening widgets that the image has changed, so they can rebuild.
    notifyListeners();
  }

  /// Picks an image from the device's gallery using [ImagePicker].
  ///
  /// This method is kept for potential future use but is currently
  /// not called from the main UI flow, which now uses the document scanner.
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    }
  }

  /// Clears the current image from the state.
  void clearImage() {
    _image = null;
    notifyListeners();
  }
}
