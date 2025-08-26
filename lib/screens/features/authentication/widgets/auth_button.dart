import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/screens/features/authentication/login_form_screen.dart';
import 'package:tiktok_clone/screens/features/authentication/username_screen.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final FaIcon icon;
  final String type;

  const AuthButton({
    super.key,
    required this.text,
    required this.icon,
    this.type = "email",
  });

  void onTap(BuildContext context) {
    if (type.contains("login")) {
      _onEmailLoginTap(context);
    } else if (type == "email") {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const UsernameScreen()));
    } else if (type == "apple") {
      // Handle Apple sign-in
    } else {
      // Handle other types if necessary
    }
  }

  void _onEmailLoginTap(BuildContext context) {
    if (type == "login_email") {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const LoginFormScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: Sizes.size1),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(alignment: Alignment.centerLeft, child: icon),
              Text(
                text,
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
