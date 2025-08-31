import 'package:flutter/foundation.dart';
import '../utils/image_cropper_service.dart';

class FlashcardProvider with ChangeNotifier {
  List<CroppedImage> _croppedImages = [];

  List<CroppedImage> get croppedImages => _croppedImages;

  void setCroppedImages(List<CroppedImage> images) {
    _croppedImages = images;
    notifyListeners();
  }

  // New method to handle reordering
  void reorderFlashcards(int oldIndex, int newIndex) {
    final item = _croppedImages.removeAt(oldIndex);
    _croppedImages.insert(newIndex, item);
    notifyListeners(); // Notify listeners of the change
  }

  void clear() {
    _croppedImages.clear();
    notifyListeners();
  }
    void addCroppedImages(List<CroppedImage> newImages) {
    _croppedImages.addAll(newImages);
    notifyListeners();
  }
}
