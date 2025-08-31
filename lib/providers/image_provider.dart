import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// This provider now manages a list of images for batch processing.
class ImageStateProvider with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  /// The list of all images selected for the current batch.
  List<File> _imageList = [];
  List<File> get imageList => _imageList;

  /// The index of the image currently being edited.
  int _currentIndex = -1;
  int get currentIndex => _currentIndex;

  /// The image that is currently active in the editor.
  File? get currentImage => _currentIndex != -1 ? _imageList[_currentIndex] : null;

  /// Replaces the entire image list with a new list of [XFile]s from the picker.
  Future<void> pickMultipleImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      _imageList = pickedFiles.map((file) => File(file.path)).toList();
      // Set the first image as the current one to start.
      _currentIndex = 0;
      notifyListeners();
    }
  }
  void startNewBatchWithSingleImage(File image) {
    _imageList = [image]; // Create a new list with just this image
    _currentIndex = 0;   // Set it as the current item
    notifyListeners();
  }
  /// Sets the currently active image by its index in the list.
  void setCurrentIndex(int index) {
    if (index >= 0 && index < _imageList.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }
 void replaceImageAtIndex(int index, File newImage) {
    if (index >= 0 && index < _imageList.length) {
      _imageList[index] = newImage;
      // Notify listeners so the StagingScreen updates its thumbnail.
      notifyListeners();
    }
  }
  /// Clears all images and resets the state.
  void clearAll() {
    _imageList = [];
    _currentIndex = -1;
    notifyListeners();
  }
}
