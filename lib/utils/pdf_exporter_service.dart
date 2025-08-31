import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img; // Import the image package
import 'image_cropper_service.dart';

class PdfExporterService {
  static Future<void> exportToPdf({
    required List<CroppedImage> images,
    String fileName = "Flashcards.pdf",
  }) async {
    // 1. Create a new PDF document
    final pdf = pw.Document();

    // 2. Process and convert our image data
    final List<pw.ImageProvider> pdfImages = [];
    for (var croppedImage in images) {
      // THE FIX: Decode and re-encode the image to ensure it's a standard format.
      // This step cleans up any potential corruption or format issues from the source.
      final img.Image? image = img.decodeImage(croppedImage.imageBytes);
      if (image != null) {
        // Re-encode as a standard JPG.
        final cleanedBytes = Uint8List.fromList(img.encodeJpg(image));
        // Add the cleaned image to the list for the PDF.
        pdfImages.add(pw.MemoryImage(cleanedBytes));
      }
    }

    // 3. Add pages to the PDF, arranging images in a grid
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.GridView(
              crossAxisCount: 2,
              childAspectRatio: 1.5, // Rectangular flashcard shape
              children: pdfImages.map((image) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1),
                    ),
                    child: pw.Image(image, fit: pw.BoxFit.contain),
                  ),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    // 4. Get a temporary directory to save the file
    final outputDir = await getTemporaryDirectory();
    final file = File("${outputDir.path}/$fileName");
    await file.writeAsBytes(await pdf.save());

    // 5. Use the share_plus package to share the file
    await Share.shareXFiles([XFile(file.path)], text: 'Here are your flashcards!');
  }
}
