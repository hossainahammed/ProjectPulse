import 'package:flutter/material.dart';
import 'dart:ui';

class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Background
        Container(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF020617) 
              : const Color(0xFFF8FAFC),
        ),
        
        if (Theme.of(context).brightness == Brightness.dark) ...[
          // Soft Purple Blob Top Left
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD946EF).withOpacity(0.15),
              ),
            ),
          ),
          
          // Soft Blue Blob Bottom Right
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.15),
              ),
            ),
          ),
          
          // Blur Layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),
        ],
        
        child,
      ],
    );
  }
}
