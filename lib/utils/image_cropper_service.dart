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
  static Future<List<CroppedImage>> cropImageWithRulers({
    required Uint8List imageBytes,
    required List<Ruler> rulers,
    required Size displayedImageSize,
    required Offset imageOffset, // This contains the top-left corner of the image
    required int startingId,
  }) async {
    final List<CroppedImage> croppedImages = [];
    final img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) return [];

    final double scaleX = originalImage.width / displayedImageSize.width;
    final double scaleY = originalImage.height / displayedImageSize.height;

    final horizontalRulers = rulers.where((r) => r.orientation == RulerOrientation.horizontal).toList();
    final verticalRulers = rulers.where((r) => r.orientation == RulerOrientation.vertical).toList();

    horizontalRulers.sort((a, b) => a.position.compareTo(b.position));
    verticalRulers.sort((a, b) => a.position.compareTo(b.position));

    // --- START OF THE FIX ---

    // 1. Define the image's boundaries in the widget coordinate system.
    final double imageStartX = imageOffset.dx;
    final double imageEndX = imageOffset.dx + displayedImageSize.width;
    final double imageStartY = imageOffset.dy;
    final double imageEndY = imageOffset.dy + displayedImageSize.height;

    // 2. Create the list of cuts using the correct image boundaries, not the canvas boundaries.
    final List<double> horizontalCuts = [
      imageStartY, // Use the image's top edge
      ...horizontalRulers.map((r) => r.position),
      imageEndY,   // Use the image's bottom edge
    ];
    final List<double> verticalCuts = [
      imageStartX, // Use the image's left edge
      ...verticalRulers.map((r) => r.position),
      imageEndX,   // Use the image's right edge
    ];

    // --- END OF THE FIX ---

    int idCounter = startingId;

    for (int i = 0; i < horizontalCuts.length - 1; i++) {
      for (int j = 0; j < verticalCuts.length - 1; j++) {
        // The rest of the logic works perfectly with these corrected boundaries.
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
        croppedImages.add(CroppedImage(id: idCounter++, imageBytes: Uint8List.fromList(encodedImage)));
      }
    }

    return croppedImages;
  }
}
