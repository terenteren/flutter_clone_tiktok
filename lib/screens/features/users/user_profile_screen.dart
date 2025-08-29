import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/screens/features/users/widgets/user_stats_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  void _onLinkTap() async {
    final url = Uri.parse("https://github.com/terenteren/flutter_clone_tiktok");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("FIFA"),
            actions: [
              IconButton(
                onPressed: () {},
                icon: FaIcon(FontAwesomeIcons.gear, size: Sizes.size20),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal,
                  foregroundImage: NetworkImage(
                    "https://avatars.githubusercontent.com/u/33644179?v=4",
                  ),
                  child: Text("테렌"),
                ),
                Gaps.v20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "@테렌",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: Sizes.size18,
                      ),
                    ),
                    Gaps.h5,
                    FaIcon(
                      FontAwesomeIcons.solidCircleCheck,
                      color: Colors.blue.shade500,
                      size: Sizes.size16,
                    ),
                  ],
                ),
                Gaps.v24,
                SizedBox(
                  height: Sizes.size48,
                  child: UserStatsBar(
                    following: "97",
                    followers: "10M",
                    likes: "194.3M",
                  ),
                ),
                Gaps.v14,
                FractionallySizedBox(
                  widthFactor: 0.33,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: Sizes.size12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(
                        Radius.circular(Sizes.size4),
                      ),
                    ),
                    child: Text(
                      "follow",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Gaps.v14,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.size32),
                  child: Text(
                    "Just FIFA things #fifa #fifaworldcup #worldcup #football #soccer #축구",
                    style: TextStyle(fontSize: Sizes.size16),
                    textAlign: TextAlign.center,
                  ),
                ),
                Gaps.v14,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.link, size: Sizes.size16),
                    Gaps.h4,
                    InkWell(
                      onTap: _onLinkTap,
                      child: Text(
                        "https://github.com/terenteren",
                        style: TextStyle(
                          fontSize: Sizes.size16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                Gaps.v14,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
