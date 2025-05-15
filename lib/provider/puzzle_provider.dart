
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:snap_split/models/puzzle_model.dart';

class PuzzleProvider with ChangeNotifier {
  String? _imagePath;
  int _gridSize = 3;
  List<PuzzleTile> _tiles = [];
  int _moves = 0;
  DateTime? _startTime;
  bool _isShowingOriginal = false;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool _isSolved = false;

  String? get imagePath => _imagePath;
  int get gridSize => _gridSize;
  List<PuzzleTile> get tiles => _tiles;
  int get moves => _moves;
  bool get isShowingOriginal => _isShowingOriginal;
  bool get isSolved => _isSolved;

  String get formattedTime {
    final minutes = _elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsedTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void setImagePath(String path) {
    _imagePath = path;
    notifyListeners();
  }

  void setGridSize(int size) {
    _gridSize = size;
    notifyListeners();
  }

  void showOriginalImage() {
    _isShowingOriginal = true;
    notifyListeners();
  }

  void hideOriginalImage() {
    _isShowingOriginal = false;
    notifyListeners();
  }

  Future<void> createPuzzleTiles() async {
    if (_imagePath == null) return;

    // Reset state
    _tiles = [];
    _moves = 0;
    _isSolved = false;
    _elapsedTime = Duration.zero;
    _startTimer();

    // Load and decode the image
    final imageFile = File(_imagePath!);
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) return;

    // Calculate tile dimensions
    final int tileWidth = image.width ~/ _gridSize;
    final int tileHeight = image.height ~/ _gridSize;

    // Create tiles
    for (int y = 0; y < _gridSize; y++) {
      for (int x = 0; x < _gridSize; x++) {
        final isBlank = x == _gridSize - 1 && y == _gridSize - 1;

        // Create a cropped image for the tile
        final tileImage = img.copyCrop(
          image,
          x: x * tileWidth,
          y: y * tileHeight,
          width: tileWidth,
          height: tileHeight,
        );

        // Convert the tile image to bytes
        final tileBytes = isBlank
            ? Uint8List(0) // Blank tile has no image
            : Uint8List.fromList(img.encodePng(tileImage));

        _tiles.add(PuzzleTile(
          value: y * _gridSize + x,
          correctX: x,
          correctY: y,
          currentX: x,
          currentY: y,
          isBlank: isBlank,
          imageBytes: tileBytes,
        ));
      }
    }

    // Shuffle the tiles
    shufflePuzzle();
  }

  void _startTimer() {
    _startTime = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime = DateTime.now().difference(_startTime!);
      notifyListeners();
    });
  }

  void shufflePuzzle() {
    final random = Random();
    for (int i = 0; i < 100; i++) {
      final blankTile = _tiles.firstWhere((tile) => tile.isBlank);

      final movableTiles = _tiles.where((tile) =>
      (tile.currentX == blankTile.currentX && (tile.currentY - blankTile.currentY).abs() == 1) ||
          (tile.currentY == blankTile.currentY && (tile.currentX - blankTile.currentX).abs() == 1)
      ).toList();

      if (movableTiles.isNotEmpty) {
        final tileToMove = movableTiles[random.nextInt(movableTiles.length)];

        final tempX = blankTile.currentX;
        final tempY = blankTile.currentY;

        final blankIndex = _tiles.indexWhere((tile) => tile.isBlank);
        final tileIndex = _tiles.indexWhere((tile) =>
        tile.currentX == tileToMove.currentX && tile.currentY == tileToMove.currentY
        );

        _tiles[blankIndex] = blankTile.copyWith(
          currentX: tileToMove.currentX,
          currentY: tileToMove.currentY,
        );

        _tiles[tileIndex] = tileToMove.copyWith(
          currentX: tempX,
          currentY: tempY,
        );
      }
    }

    // Reset moves counter when shuffling
    _moves = 0;
    _elapsedTime = Duration.zero;
    _startTimer();

    notifyListeners();
  }

  void moveTile(PuzzleTile tile) {
    // Find the blank tile
    final blankTile = _tiles.firstWhere((t) => t.isBlank);

    // Check if the tile is adjacent to the blank tile
    final isAdjacent =
        (tile.currentX == blankTile.currentX && (tile.currentY - blankTile.currentY).abs() == 1) ||
            (tile.currentY == blankTile.currentY && (tile.currentX - blankTile.currentX).abs() == 1);

    if (isAdjacent) {
      // Swap positions
      final tempX = blankTile.currentX;
      final tempY = blankTile.currentY;

      final blankIndex = _tiles.indexWhere((t) => t.isBlank);
      final tileIndex = _tiles.indexWhere((t) =>
      t.currentX == tile.currentX && t.currentY == tile.currentY
      );

      _tiles[blankIndex] = blankTile.copyWith(
        currentX: tile.currentX,
        currentY: tile.currentY,
      );

      _tiles[tileIndex] = tile.copyWith(
        currentX: tempX,
        currentY: tempY,
      );

      // Increment moves counter
      _moves++;

      // Check if puzzle is solved
      _checkPuzzleSolved();

      notifyListeners();
    }
  }

  void _checkPuzzleSolved() {
    _isSolved = _tiles.every((tile) => tile.isCorrect);
    if (_isSolved) {
      _timer?.cancel();
    }
  }

  void resetPuzzle() {
    if (_imagePath == null) return;

    // Reset all tiles to their original positions
    for (int i = 0; i < _tiles.length; i++) {
      final int x = i % _gridSize;
      final int y = i ~/ _gridSize;

      _tiles[i] = _tiles[i].copyWith(
        currentX: x,
        currentY: y,
      );
    }

    _moves = 0;
    _isSolved = false;
    _elapsedTime = Duration.zero;
    _startTimer();

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Background Grid Painter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1;

    // Draw horizontal lines
    double offsetY = 0;
    while (offsetY < size.height) {
      canvas.drawLine(
        Offset(0, offsetY),
        Offset(size.width, offsetY),
        paint,
      );
      offsetY += 20;
    }

    // Draw vertical lines
    double offsetX = 0;
    while (offsetX < size.width) {
      canvas.drawLine(
        Offset(offsetX, 0),
        Offset(offsetX, size.height),
        paint,
      );
      offsetX += 20;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}