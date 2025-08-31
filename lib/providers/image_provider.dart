import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// This provider now manages a list of images for batch processing.
class ImageStateProvider with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  /// The list of all images selected for the current project.
  List<File> _imageList = [];
  List<File> get imageList => _imageList;

  /// The index of the image currently being edited in the contact sheet.
  int _currentIndex = -1;
  int get currentIndex => _currentIndex;

  /// The image that is currently active in the editor.
  File? get currentImage => (_currentIndex != -1 && _imageList.isNotEmpty) ? _imageList[_currentIndex] : null;

  /// Picks images from the gallery. Can either start a new list or add to the existing one.
  Future<void> pickMultipleImages({bool addToExisting = false}) async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      final newImages = pickedFiles.map((file) => File(file.path)).toList();
      
      if (addToExisting) {
        _imageList.addAll(newImages);
      } else {
        _imageList = newImages;
      }

      // If this is the first time adding images, or we're starting a new list,
      // set the current index to the first image.
      if (_currentIndex == -1 || !addToExisting) {
        _currentIndex = 0;
      }
      notifyListeners();
    }
  }

  /// Replaces the image at a specific index with a new, adjusted one.
  void replaceImageAtIndex(int index, File newImage) {
    if (index >= 0 && index < _imageList.length) {
      _imageList[index] = newImage;
      // Notify listeners so the filmstrip thumbnail updates.
      notifyListeners();
    }
  }

  /// Sets the currently active image by its index in the list.
  void setCurrentIndex(int index) {
    if (index >= 0 && index < _imageList.length) {
      _currentIndex = index;
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
