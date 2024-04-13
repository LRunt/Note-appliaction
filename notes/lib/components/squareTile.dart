import 'package:flutter/material.dart';

/// A custom widget that displays an image within a styled square tile.
///
/// This widget creates a container with a fixed square shape, a white border,
/// rounded corners, and a light grey background. The image displayed is determined
/// by the [imagePath] provided.
///
/// The [onTap] function can be provided to handle tap events on the tile.
///
/// Usage example:
/// ```dart
/// SquareTile(imagePath: 'assets/images/my_image.png', )
/// ```
///
/// Make sure the provided [imagePath] correctly points to an asset within your project.
class SquareTile extends StatelessWidget {
  /// The path to the image asset to be displayed inside the tile.
  ///
  /// This path should be a valid asset path in the project's pubspec.yaml file.
  final String imagePath;

  /// Callback function to handle tap events on the tile.
  final Function()? onTap;

  /// Constructor of the [SquareTile].
  ///
  /// Requires two positional arguments:
  /// - [imagePath] a path to the image, what will be shown in the tile.
  /// - [onTap] the action, when the tile is touched.
  const SquareTile({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  // Builds the UI of the [SquareTile].
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: GestureDetector(
        key: const Key('tap'),
        onTap: onTap,
        child: Image.asset(
          imagePath,
          height: 40,
        ),
      ),
    );
  }
}
