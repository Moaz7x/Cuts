# FlashCut - Smart Flashcard Creator

FlashCut is a Flutter-based Android application designed to streamline the creation of flashcards from images. Users can upload photos, adjust them, precisely cut out questions and answers, and then print them as physical flashcards.

## Key Features:
- **Image Selection & Adjustment**: Upload images from your device and make necessary adjustments.
- **Precise Cutting Tool**: Utilize a customizable cutting tool to define questions and answers.
- **Flashcard Generation**: Automatically arrange cut sections into a two-column flashcard layout.
- **Export & Print**: Save flashcards, export them as PDF/image files, and print them for study.

## Project Structure (`lib` directory):

```
lib/
├── main.dart                 # Main entry point of the Flutter application.
├── models/                   # Data models for the application (e.g., Ruler, Project).
│   ├── named ruler_model.dart
│   ├── project_model.dart
│   └── ruler_model.dart
├── providers/                # State management using Provider (e.g., FlashcardProvider, ImageProvider).
│   ├── flashcard_provider.dart
│   ├── image_provider.dart
│   └── ruler_provider.dart
├── screens/                  # UI screens of the application.
│   ├── adjust/               # Screen for image adjustments.
│   │   └── adjust_screen.dart
│   ├── contact_sheet/        # Screen for contact sheet view.
│   │   ├── contact_sheet_screen.dart
│   │   └── widgets/
│   ├── cropping/             # Screen for image cropping.
│   │   └── cropping_screen.dart
│   ├── editor/               # Screen for editing flashcards.
│   │   └── editor_screen.dart
│   ├── home/                 # Home screen of the application.
│   │   └── home_screen.dart
│   └── staging/              # Screen for staging flashcards.
│       └── staging_screen.dart
├── utils/                    # Utility functions and services.
│   ├── image_adjust_service.dart
│   ├── image_cropper_service.dart
│   ├── pdf_exporter_service.dart
│   └── project_service.dart
└── widgets/                  # Reusable UI widgets.
    ├── corner_marker_widget.dart
    └── draggable_ruler_widget.dart
```

## Getting Started

  