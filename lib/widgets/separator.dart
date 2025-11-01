import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const Separator({super.key, this.height = 2.0, this.width = 5, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Container(
        color: color,
      ),
    );
  }
}
