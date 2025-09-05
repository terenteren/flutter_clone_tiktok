import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';

class VideoButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const VideoButton({
    super.key, 
    required this.icon, 
    required this.text,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FaIcon(icon, color: iconColor ?? Colors.white, size: Sizes.size36),
        Gaps.v5,
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: Sizes.size14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
