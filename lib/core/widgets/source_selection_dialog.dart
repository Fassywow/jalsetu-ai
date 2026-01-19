import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SourceSelectionDialog extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const SourceSelectionDialog({
    super.key,
    required this.title,
    required this.description,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Selection Cards
            Row(
              children: [
                Expanded(
                  child: _SelectionCard(
                    icon: Icons.camera_alt_rounded,
                    // label: "Camera",
                    color: const Color(0xFF2E3192), // Deep Blue
                    onTap: onCameraTap,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SelectionCard(
                    icon: Icons.photo_library_rounded,
                    // label: "Gallery",
                    color: const Color(0xFF00B4D8), // Cyan/Blue
                    onTap: onGalleryTap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Cancel",
                style: GoogleFonts.outfit(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final IconData icon;

  final Color color;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 32, color: color),
              ),

              // Text(
              //   label,
              //   style: GoogleFonts.outfit(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //     color: color,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
