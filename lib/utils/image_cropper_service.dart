import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/ruler_model.dart';

/// A data class to hold the generated flashcard image data along with a unique ID.
class CroppedImage {
  final int id;
  final Uint8List imageBytes;

  CroppedImage({required this.id, required this.imageBytes});
}

/// A service dedicated to handling the image cropping logic.
class ImageCropperService {
  /// Takes an image file and a list of rulers and returns a list of cropped image bytes.
  static Future<List<CroppedImage>> cropImageWithRulers({
    required File imageFile,
    required List<Ruler> rulers,
    required Size displayedImageSize,
    required Offset imageOffset,
    required int startingId, // This is the crucial addition
  }) async {
    final List<CroppedImage> croppedImages = [];
    final imageBytes = await imageFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) return [];

    final double scaleX = originalImage.width / displayedImageSize.width;
    final double scaleY = originalImage.height / displayedImageSize.height;

    final horizontalRulers = rulers.where((r) => r.orientation == RulerOrientation.horizontal).toList();
    final verticalRulers = rulers.where((r) => r.orientation == RulerOrientation.vertical).toList();

    horizontalRulers.sort((a, b) => a.position.compareTo(b.position));
    verticalRulers.sort((a, b) => a.position.compareTo(b.position));

    final List<double> horizontalCuts = [0, ...horizontalRulers.map((r) => r.position), displayedImageSize.height];
    final List<double> verticalCuts = [0, ...verticalRulers.map((r) => r.position), displayedImageSize.width];

    // Initialize the counter with the provided starting ID.
    int idCounter = startingId;

    for (int i = 0; i < horizontalCuts.length - 1; i++) {
      for (int j = 0; j < verticalCuts.length - 1; j++) {
        final double y1 = (horizontalCuts[i] - imageOffset.dy) * scaleY;
        final double y2 = (horizontalCuts[i + 1] - imageOffset.dy) * scaleY;
        final double x1 = (verticalCuts[j] - imageOffset.dx) * scaleX;
        final double x2 = (verticalCuts[j + 1] - imageOffset.dx) * scaleX;

        final int width = (x2 - x1).round();
        final int height = (y2 - y1).round();

        if (width <= 0 || height <= 0) continue;

        final img.Image croppedPart = img.copyCrop(
          originalImage,
          x: x1.round(),
          y: y1.round(),
          width: width,
          height: height,
        );

        final encodedImage = img.encodePng(croppedPart);
        // Use the globally unique ID.
        croppedImages.add(CroppedImage(id: idCounter++, imageBytes: Uint8List.fromList(encodedImage)));
      }
    }

    return croppedImages;
  }
}
