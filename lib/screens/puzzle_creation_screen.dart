// Puzzle Creation Page
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:snap_split/provider/puzzle_provider.dart';
import 'package:snap_split/screens/widgets/puzzle_board_widget.dart';

class PuzzleCreationPage extends StatefulWidget {
  const PuzzleCreationPage({Key? key}) : super(key: key);

  @override
  State<PuzzleCreationPage> createState() => _PuzzleCreationPageState();
}

class _PuzzleCreationPageState extends State<PuzzleCreationPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    // Create puzzle pieces
    _createPuzzle();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createPuzzle() async {
    final provider = Provider.of<PuzzleProvider>(context, listen: false);
    await provider.createPuzzleTiles();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PuzzleProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Your Puzzle',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _isLoading ? null : () => _sharePuzzle(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          const SizedBox(height: 20),

          // Progress and moves count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Moves counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Moves: ${provider.moves}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer/Elapsed time
                Consumer<PuzzleProvider>(
                  builder: (context, puzzleProvider, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            puzzleProvider.formattedTime,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Puzzle board
          Expanded(
            child: Center(
              child: ScaleTransition(
                scale: _animation,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Grid lines
                        GridPaper(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          divisions: 1,
                          subdivisions: provider.gridSize,
                        ),

                        // Puzzle pieces
                        provider.tiles.isEmpty
                            ? const SizedBox()
                            : PuzzleBoard(
                          tiles: provider.tiles,
                          gridSize: provider.gridSize,
                        ),

                        // Show original image button (peek)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onLongPress: () {
                              provider.showOriginalImage();
                            },
                            onLongPressEnd: (_) {
                              provider.hideOriginalImage();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.remove_red_eye,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 16,
                              ),
                            ),
                          ),
                        ),

                        // Display original image when peeking
                        if (provider.isShowingOriginal)
                          Positioned.fill(
                            child: Hero(
                              tag: 'original_image',
                              child: Image.file(
                                File(provider.imagePath!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  Icons.refresh_rounded,
                  'Reset',
                  Theme.of(context).colorScheme.error,
                      () => provider.resetPuzzle(),
                ),
                _buildActionButton(
                  context,
                  Icons.shuffle_rounded,
                  'Shuffle',
                  Theme.of(context).colorScheme.tertiary,
                      () => provider.shufflePuzzle(),
                ),
                _buildActionButton(
                  context,
                  Icons.help_outline_rounded,
                  'Hint',
                  Theme.of(context).colorScheme.secondary,
                      () => _showHint(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePuzzle(BuildContext context) async {
    final provider = Provider.of<PuzzleProvider>(context, listen: false);

    // Get directory to save the puzzle file
    final directory = await getApplicationDocumentsDirectory();
    final puzzleFilePath = '${directory.path}/puzzle_${DateTime.now().millisecondsSinceEpoch}.png';

    // Save the image file
    final File puzzleFile = File(puzzleFilePath);
    await puzzleFile.writeAsBytes(await File(provider.imagePath!).readAsBytes());

    // Share the puzzle
    // await Share.shareFiles(
    //   [puzzleFilePath],
    //   text: 'Can you solve this SnapSplit puzzle? Grid size: ${provider.gridSize}x${provider.gridSize}',
    // );
  }

  void _showHint(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Image.file(
                    File(Provider.of<PuzzleProvider>(context).imagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Hint',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Look at the original image and try to move the pieces one by one to match it.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}