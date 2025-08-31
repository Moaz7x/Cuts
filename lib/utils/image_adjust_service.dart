import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// A service for performing perspective transformation on an image.
class ImageAdjustService {
  /// Takes an image and four corner points, and returns a new, flattened image file.
  static Future<File?> adjustPerspective(File originalImageFile, List<Offset> corners) async {
    final bytes = await originalImageFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) return null;

    // The four corners from the UI, in order: topLeft, topRight, bottomLeft, bottomRight
    final topLeft = corners[0];
    final topRight = corners[1];
    final bottomLeft = corners[2];
    final bottomRight = corners[3];

    // --- THE FIX IS HERE ---
    // Use the 'copyRectify' function which is designed for perspective correction.
    // It takes the source image and the four corner points.
    final img.Image rectifiedImage = img.copyRectify(
      originalImage,
      topLeft: img.Point(topLeft.dx, topLeft.dy),
      topRight: img.Point(topRight.dx, topRight.dy),
      bottomLeft: img.Point(bottomLeft.dx, bottomLeft.dy),
      bottomRight: img.Point(bottomRight.dx, bottomRight.dy),
    );
    // --- END OF FIX ---

    // Save the transformed image to a temporary file.
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final transformedFile = File(tempPath);
    await transformedFile.writeAsBytes(img.encodeJpg(rectifiedImage));

    return transformedFile;
  }
}
