import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingCard extends StatelessWidget {
  const ShimmerLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: currentWidth,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[300],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                height: 20,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 10),
              Container(
                width: 100,
                height: 20,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 10),
              Container(
                width: 80,
                height: 20,
                color: Colors.grey[300],
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
