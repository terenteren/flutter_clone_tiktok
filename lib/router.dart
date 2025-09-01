import 'package:go_router/go_router.dart';
import 'package:tiktok_clone/screens/features/authentication/email_screen.dart';
import 'package:tiktok_clone/screens/features/authentication/login_form_screen.dart';
import 'package:tiktok_clone/screens/features/authentication/login_screen.dart';
import 'package:tiktok_clone/screens/features/authentication/sign_up_screen.dart';
import 'package:tiktok_clone/screens/features/authentication/username_screen.dart';
import 'package:tiktok_clone/screens/features/users/user_profile_screen.dart';
import 'package:tiktok_clone/screens/features/videos/video_recording_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const VideoRecordingScreen(),
    ),
  ],
);
