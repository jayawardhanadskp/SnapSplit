// Puzzle Board Widget
import 'package:flutter/material.dart';
import 'package:snap_split/models/puzzle_model.dart';
import 'package:snap_split/screens/widgets/puzzle_tile_widget.dart';

class PuzzleBoard extends StatelessWidget {
  final List<PuzzleTile> tiles;
  final int gridSize;

  const PuzzleBoard({
    Key? key,
    required this.tiles,
    required this.gridSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = constraints.maxWidth / gridSize;
        return Stack(
          children: [
            for (final tile in tiles)
              if (!tile.isBlank)
                Positioned(
                  left: tile.currentX * tileSize,
                  top: tile.currentY * tileSize,
                  width: tileSize,
                  height: tileSize,
                  child: PuzzleTileWidget(
                    tile: tile,
                    size: tileSize,
                  ),
                ),
          ],
        );
      },
    );
  }
}