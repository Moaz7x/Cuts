import 'dart:io';
import 'dart:math'; // Import the dart:math library for max() and min()

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'image_cropper_service.dart';

class PdfExporterService {
  static Future<void> exportToPdf({
    required List<CroppedImage> images,
    String fileName = "Flashcards.pdf",
  }) async {
    final pdf = pw.Document();

    // --- START OF THE INVERTED LOGIC ---

    double maxWidth = 0;
    double maxHeight = 0;
    final List<pw.ImageProvider> pdfImages = [];

    for (var croppedImage in images) {
      final img.Image? image = img.decodeImage(croppedImage.imageBytes);
      if (image != null) {
        if (image.width > maxWidth) {
          maxWidth = image.width.toDouble();
        }
        if (image.height > maxHeight) {
          maxHeight = image.height.toDouble();
        }
        final cleanedBytes = Uint8List.fromList(img.encodeJpg(image));
        pdfImages.add(pw.MemoryImage(cleanedBytes));
      }
    }

    // THE FIX: Invert width and height to force a portrait aspect ratio.
    double finalAspectRatio;

    if (maxWidth > 0 && maxHeight > 0) {
      // 1. Find the larger and smaller of the two dimensions.
      final double majorAxis = max(maxWidth, maxHeight);
      final double minorAxis = min(maxWidth, maxHeight);

      // 2. Calculate a guaranteed PORTRAIT aspect ratio (always <= 1.0)
      //    by putting the smaller dimension on top.
      final double portraitAspectRatio = minorAxis / majorAxis;

      // 3. Clamp this ratio to a sensible range for portrait cards.
      //    A typical playing card is ~0.7. We'll use a similar range.
      const double minSensibleAspectRatio = 0.5; // Prevents cards from being too tall/thin.
      const double maxSensibleAspectRatio = 0.9; // Prevents cards from being almost square.
      finalAspectRatio = portraitAspectRatio.clamp(minSensibleAspectRatio, maxSensibleAspectRatio);
    } else {
      // Default to a standard portrait ratio if no images were processed.
      finalAspectRatio = 0.7;
    }

    // --- END OF THE INVERTED LOGIC ---

    pw.ThemeData? theme;
    try {
      theme = pw.ThemeData.withFont(
        base: pw.Font.ttf(await rootBundle.load("assets/fonts/OpenSans-Regular.ttf")),
        bold: pw.Font.ttf(await rootBundle.load("assets/fonts/OpenSans-Bold.ttf")),
      );
    } catch (e) {
      print("Font loading failed: $e. Using default font.");
      theme = pw.ThemeData.base();
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: const pw.EdgeInsets.all(30),
        ),
        header: (pw.Context context) {
          if (context.pageNumber == 1) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Your Flashcards',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
              ],
            );
          }
          return pw.Container();
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 10.0),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.GridView(
              crossAxisCount: 2,
              childAspectRatio: finalAspectRatio,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: pdfImages.map((image) {
                return pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey600, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.ClipRRect(
                    horizontalRadius: 4,
                    verticalRadius: 4,
                    child: pw.Image(image, fit: pw.BoxFit.fill),
                  ),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    // Save and share the document
    final outputDir = await getTemporaryDirectory();
    final file = File("${outputDir.path}/$fileName");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Here are your flashcards!');
  }
}
