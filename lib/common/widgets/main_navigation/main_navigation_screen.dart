import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tiktok_clone/constants/breakpoint.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/constants/utils.dart';
import 'package:tiktok_clone/screens/features/discover/discover_screen.dart';
import 'package:tiktok_clone/screens/features/inbox/inbox_screen.dart';
import 'package:tiktok_clone/common/widgets/main_navigation/widgets/nav_tab.dart';
import 'package:tiktok_clone/common/widgets/main_navigation/widgets/post_video_button.dart';
import 'package:tiktok_clone/screens/features/users/user_profile_screen.dart';
import 'package:tiktok_clone/screens/features/videos/views/video_recording_screen.dart';
import 'package:tiktok_clone/screens/features/videos/views/video_timeline_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  static const String routeName = "mainNavigation";

  final String tab;

  const MainNavigationScreen({super.key, required this.tab});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final List<String> _tabs = ["home", "discover", "xxxx", "inbox", "profile"];

  late int _selectedIndex = _tabs.indexOf(widget.tab);

  final screens = [
    Center(child: Text("Home", style: TextStyle(fontSize: 49))),
    Center(child: Text("Discover", style: TextStyle(fontSize: 49))),
    Container(),
    Center(child: Text("Inbox", style: TextStyle(fontSize: 49))),
    Center(child: Text("Profile", style: TextStyle(fontSize: 49))),
  ];

  void _onTap(int index) {
    context.go("/${_tabs[index]}");

    setState(() {
      _selectedIndex = index;
    });
  }

  void _onPostVideoButtonTap() {
    context.pushNamed(VideoRecordingScreen.routeName);
  }

  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return VideoTimelineScreen();
      case 1:
        return DiscoverScreen();
      case 3:
        return InboxScreen();
      case 4:
        return UserProfileScreen(username: "테렌", tab: "");
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDark = isDarkMode(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _selectedIndex == 0 || isDark
          ? Colors.black
          : Colors.white,
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: width > Breakpoints.sm ? Breakpoints.md : double.infinity,
          ),
          child: _buildSelectedScreen(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Container(
          color: _selectedIndex == 0 || isDark ? Colors.black : Colors.white,
          padding: EdgeInsets.only(bottom: Sizes.size32),
          child: Padding(
            padding: const EdgeInsets.all(Sizes.size12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NavTab(
                  text: "Home",
                  isSElected: _selectedIndex == 0,
                  icon: FontAwesomeIcons.house,
                  selectedIcon: FontAwesomeIcons.house,
                  onTap: () => _onTap(0),
                  selectedIndex: _selectedIndex,
                ),
                NavTab(
                  text: "Discover",
                  isSElected: _selectedIndex == 1,
                  icon: FontAwesomeIcons.compass,
                  selectedIcon: FontAwesomeIcons.solidCompass,
                  onTap: () => _onTap(1),
                  selectedIndex: _selectedIndex,
                ),
                Gaps.h24,
                GestureDetector(
                  onTap: _onPostVideoButtonTap,
                  child: PostVideoButton(inverted: _selectedIndex != 0),
                ),
                Gaps.h24,
                NavTab(
                  text: "Inbox",
                  isSElected: _selectedIndex == 3,
                  icon: FontAwesomeIcons.message,
                  selectedIcon: FontAwesomeIcons.solidMessage,
                  onTap: () => _onTap(3),
                  selectedIndex: _selectedIndex,
                ),
                NavTab(
                  text: "Profile",
                  isSElected: _selectedIndex == 4,
                  icon: FontAwesomeIcons.user,
                  selectedIcon: FontAwesomeIcons.solidUser,
                  onTap: () => _onTap(4),
                  selectedIndex: _selectedIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
