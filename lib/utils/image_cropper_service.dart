import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/ruler_model.dart';

/// A simple data class to hold the result of a single crop operation.
/// It contains a unique ID and the image data as a byte list.
class CroppedImage {
  final int id;
  final Uint8List imageBytes;
  CroppedImage({required this.id, required this.imageBytes});
}

/// A service class containing the static method to perform the cropping logic.
class ImageCropperService {
  /// Crops a single image into multiple smaller images based on ruler positions.
  ///
  /// This function takes the original [imageFile], the list of [rulers],
  /// the on-screen [displayedImageSize] of the image widget, and the [imageOffset]
  /// which is the padding around the image within its container.
  static Future<List<CroppedImage>> cropImageWithRulers({
    required File imageFile,
    required List<Ruler> rulers,
    required Size displayedImageSize,
    required Offset imageOffset, // Accepts the offset for accurate calculations
  }) async {
    // 1. Read the file and decode it into an image object.
    final imageBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      return [];
    }

    // 2. Separate rulers into horizontal and vertical lists and sort them.
    final horizontalRulers = rulers.where((r) => r.orientation == RulerOrientation.horizontal).toList();
    final verticalRulers = rulers.where((r) => r.orientation == RulerOrientation.vertical).toList();

    horizontalRulers.sort((a, b) => a.position.compareTo(b.position));
    verticalRulers.sort((a, b) => a.position.compareTo(b.position));

    // 3. Calculate the scaling factor between the on-screen image and the original file.
    final scaleX = originalImage.width / displayedImageSize.width;
    final scaleY = originalImage.height / displayedImageSize.height;

    // 4. THE FIX: Create lists of cut points, adjusting for the image's offset.
    // This makes the ruler positions relative to the image's top-left corner,
    // correcting for any centering/padding.
    final List<double> xCuts = [
      0.0, // Start at the left edge of the image
      ...verticalRulers.map((r) => r.position - imageOffset.dx),
      displayedImageSize.width, // End at the right edge of the image
    ];
    final List<double> yCuts = [
      0.0, // Start at the top edge of the image
      ...horizontalRulers.map((r) => r.position - imageOffset.dy),
      displayedImageSize.height, // End at the bottom edge of the image
    ];

    final List<CroppedImage> croppedImages = [];
    int idCounter = 0;

    // 5. Loop through the grid defined by the cut points.
    for (int i = 0; i < yCuts.length - 1; i++) {
      for (int j = 0; j < xCuts.length - 1; j++) {
        // Clamp values to prevent negative dimensions from floating point errors or rulers outside the image.
        final x1 = xCuts[j].clamp(0.0, displayedImageSize.width) * scaleX;
        final y1 = yCuts[i].clamp(0.0, displayedImageSize.height) * scaleY;
        final x2 = xCuts[j + 1].clamp(0.0, displayedImageSize.width) * scaleX;
        final y2 = yCuts[i + 1].clamp(0.0, displayedImageSize.height) * scaleY;

        final width = (x2 - x1).round();
        final height = (y2 - y1).round();

        // Skip any invalid or zero-sized crops.
        if (width <= 0 || height <= 0) continue;

        // 6. Perform the crop operation using the 'image' package.
        final croppedPart = img.copyCrop(
          originalImage,
          x: x1.round(),
          y: y1.round(),
          width: width,
          height: height,
        );

        // 7. Encode the cropped part as a PNG and add it to our results list.
        final encodedImage = img.encodePng(croppedPart);
        croppedImages.add(CroppedImage(id: idCounter++, imageBytes: Uint8List.fromList(encodedImage)));
      }
    }

    return croppedImages;
  }
}
