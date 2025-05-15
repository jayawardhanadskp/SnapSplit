// Grid Selection Page
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_split/main.dart';
import 'package:snap_split/provider/puzzle_provider.dart';
import 'package:snap_split/screens/puzzle_creation_screen.dart';

class GridSelectionPage extends StatelessWidget {
  const GridSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PuzzleProvider>(context);
    final imagePath = provider.imagePath;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Choose Grid Size',
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
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Preview of selected image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: MediaQuery.of(context).size.width * 0.7,
                width: MediaQuery.of(context).size.width - 48,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: imagePath != null
                    ? Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                )
                    : Container(color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 40),

          Text(
            'Select puzzle difficulty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 30),

          // Grid size options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildGridOption(context, '3 x 3', 3, 'Easy'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGridOption(context, '4 x 4', 4, 'Medium'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridOption(context, '5 x 5', 5, 'Hard'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGridOption(context, '6 x 6', 6, 'Expert'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridOption(BuildContext context, String title, int gridSize, String difficulty) {
    final Color difficultyColor = difficulty == 'Easy'
        ? Colors.green
        : difficulty == 'Medium'
        ? Colors.orange
        : difficulty == 'Hard'
        ? Colors.red
        : Colors.purple;

    return InkWell(
      onTap: () {
        Provider.of<PuzzleProvider>(context, listen: false).setGridSize(gridSize);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const PuzzleCreationPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              difficultyColor.withOpacity(0.1),
              difficultyColor.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: difficultyColor.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: difficultyColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                difficulty,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: difficultyColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}