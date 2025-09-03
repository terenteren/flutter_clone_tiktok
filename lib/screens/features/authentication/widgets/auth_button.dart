import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/screens/features/authentication/login_form_screen.dart';
import 'package:tiktok_clone/screens/features/authentication/username_screen.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final FaIcon icon;
  final String type;
  final VoidCallback? customOnTap;  // 커스텀 onTap 추가

  const AuthButton({
    super.key,
    required this.text,
    required this.icon,
    this.type = "email",
    this.customOnTap,  // 외부에서 전달받는 onTap
  });

  void onTap(BuildContext context) {
    switch (type) {
      case "email":
        // Sign up with email
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UsernameScreen()),
        );
        break;
      case "apple":
        // Sign up with Apple
        // TODO: Implement Apple sign up
        break;
      case "login_email":
        // Login with email
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginFormScreen()),
        );
        break;
      case "login_apple":
        // Login with Apple
        // TODO: Implement Apple login
        break;
      default:
        // Handle other types if necessary
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: customOnTap ?? () => onTap(context),  // customOnTap이 있으면 사용, 없으면 기본 onTap
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
