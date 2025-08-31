import 'package:flutter/foundation.dart';

import '../utils/image_cropper_service.dart';

/// This provider manages the state of the final list of cropped flashcards.
/// It accumulates images from multiple sources before the final export.
class FlashcardProvider with ChangeNotifier {
  final List<CroppedImage> _croppedImages = [];

  /// The consolidated list of all flashcard images from the current batch.
  List<CroppedImage> get croppedImages => _croppedImages;

  /// Adds a new list of images to the existing list.
  void addCroppedImages(List<CroppedImage> newImages) {
    _croppedImages.addAll(newImages);
    notifyListeners();
  }

  /// Replaces the entire list of images with a new one.
  void setCroppedImages(List<CroppedImage> newImages) {
    _croppedImages.clear();
    _croppedImages.addAll(newImages);
    notifyListeners();
  }

  /// Clears all flashcards from the state.
  void clear() {
    _croppedImages.clear();
    notifyListeners();
  }

  /// Reorders a flashcard from an old index to a new index.
  void reorderFlashcards(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final CroppedImage item = _croppedImages.removeAt(oldIndex);
    _croppedImages.insert(newIndex, item);
    notifyListeners();
  }
}
