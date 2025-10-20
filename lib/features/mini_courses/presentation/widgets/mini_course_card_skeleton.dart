import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';

class MiniCourseCardSkeleton extends StatelessWidget {
  const MiniCourseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 150.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 24.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(width: 200, height: 16, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}