import 'package:flutter/material.dart';

/// A custom widget that displays an image within a styled square tile.
///
/// This widget creates a container with a fixed square shape, a white border,
/// rounded corners, and a light grey background. The image displayed is determined
/// by the [imagePath] provided.
///
/// Usage example:
/// ```dart
/// SquareTile(imagePath: 'assets/images/my_image.png')
/// ```
///
/// Make sure the provided [imagePath] correctly points to an asset within your project.
class SquareTile extends StatelessWidget {
  /// The path to the image asset to be displayed inside the tile.
  ///
  /// This path should be a valid asset path in the project's pubspec.yaml file.
  final String imagePath;

  /// Constructor of the [SquareTile].
  ///
  /// Requires an [imagePath] to be provided, which determines the image to display.
  const SquareTile({
    super.key,
    required this.imagePath,
  });

  // Builds the UI of the [SquareTile].
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: Image.asset(
        imagePath,
        height: 40,
      ),
    );
  }
}
