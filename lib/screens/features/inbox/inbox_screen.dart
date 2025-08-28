import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/screens/features/inbox/activity_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  void _onDmPressed() {
    print("DM Clicked");
  }

  void _onActivityTap(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => ActivityScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("Inbox"),
        actions: [
          IconButton(
            onPressed: _onDmPressed,
            icon: FaIcon(FontAwesomeIcons.paperPlane),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () => _onActivityTap(context),
            title: Text(
              "Activity",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Sizes.size18,
              ),
            ),
            trailing: FaIcon(
              FontAwesomeIcons.chevronRight,
              size: Sizes.size16,
              color: Colors.black,
            ),
          ),
          Container(
            color: Colors.grey.shade200,
            child: SizedBox(height: Sizes.size1),
          ),
          ListTile(
            leading: Container(
              width: Sizes.size52,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(FontAwesomeIcons.users, color: Colors.white),
              ),
            ),
            title: Text(
              "New followers",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Sizes.size18,
              ),
            ),
            subtitle: Text(
              "messages from followers will appear here",
              style: TextStyle(fontSize: Sizes.size12, color: Colors.black54),
            ),
            trailing: FaIcon(
              FontAwesomeIcons.chevronRight,
              size: Sizes.size16,
              color: Colors.black,
            ),
          ),
          Container(
            color: Colors.grey.shade200,
            child: SizedBox(height: Sizes.size1),
          ),
        ],
      ),
    );
  }
}
