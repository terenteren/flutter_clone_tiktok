import 'package:flutter/material.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';

class UserStatsBar extends StatelessWidget {
  const UserStatsBar({
    super.key,
    required this.followers,
    required this.likes,
    required this.following,
  });

  final String followers;
  final String likes;
  final String following;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              following,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Sizes.size16,
              ),
            ),
            Gaps.v2,
            Text(
              "Following",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: Sizes.size14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        VerticalDivider(
          width: Sizes.size32,
          thickness: Sizes.size1,
          color: Colors.grey.shade400,
          indent: Sizes.size14,
          endIndent: Sizes.size14,
        ),
        Column(
          children: [
            Text(
              followers,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Sizes.size16,
              ),
            ),
            Gaps.v2,
            Text(
              "Followers",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: Sizes.size14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        VerticalDivider(
          width: Sizes.size32,
          thickness: Sizes.size1,
          color: Colors.grey.shade400,
          indent: Sizes.size14,
          endIndent: Sizes.size14,
        ),
        Column(
          children: [
            Text(
              likes,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Sizes.size16,
              ),
            ),
            Gaps.v2,
            Text(
              "Likes",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: Sizes.size14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
