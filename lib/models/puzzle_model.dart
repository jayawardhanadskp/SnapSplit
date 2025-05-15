
import 'dart:typed_data';

class PuzzleTile {
  final int value;
  final int correctX;
  final int correctY;
  int currentX;
  int currentY;
  final bool isBlank;
  final Uint8List imageBytes;

  PuzzleTile({
    required this.value,
    required this.correctX,
    required this.correctY,
    required this.currentX,
    required this.currentY,
    required this.isBlank,
    required this.imageBytes,
  });

  bool get isCorrect => correctX == currentX && correctY == currentY;

  PuzzleTile copyWith({
    int? value,
    int? correctX,
    int? correctY,
    int? currentX,
    int? currentY,
    bool? isBlank,
    Uint8List? imageBytes,
  }) {
    return PuzzleTile(
      value: value ?? this.value,
      correctX: correctX ?? this.correctX,
      correctY: correctY ?? this.correctY,
      currentX: currentX ?? this.currentX,
      currentY: currentY ?? this.currentY,
      isBlank: isBlank ?? this.isBlank,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }
}