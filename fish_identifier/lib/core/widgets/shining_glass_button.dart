import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShiningGlassButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const ShiningGlassButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.icon,
  });

  @override
  State<ShiningGlassButton> createState() => _ShiningGlassButtonState();
}

class _ShiningGlassButtonState extends State<ShiningGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          // Base Gradient Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Shining Effect
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: 0.5,
                    alignment: AlignmentTween(
                      begin: const Alignment(-2.0, 0.0),
                      end: const Alignment(2.0, 0.0),
                    ).evaluate(_controller),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0.0),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
