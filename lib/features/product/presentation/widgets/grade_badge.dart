import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/product_grade.dart';

/// Small square badge showing a product's condition grade (A/B/C).
class GradeBadge extends StatelessWidget {
  final ProductGrade grade;
  final double size;
  const GradeBadge({super.key, required this.grade, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: grade.color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        grade.label,
        style: GoogleFonts.montserrat(
          fontSize: size * 0.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
