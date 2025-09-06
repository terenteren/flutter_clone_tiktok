import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tiktok_clone/common/widgets/main_navigation/main_navigation_screen.dart';
import 'package:tiktok_clone/screens/features/authentication/login_screen.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok_clone/screens/features/authentication/sign_up_screen.dart';
import 'package:tiktok_clone/screens/features/inbox/activity_screen.dart';
import 'package:tiktok_clone/screens/features/inbox/chat_detail_screen.dart';
import 'package:tiktok_clone/screens/features/inbox/chats_screen.dart';
import 'package:tiktok_clone/screens/features/inbox/user_selection_screen.dart';
import 'package:tiktok_clone/screens/features/notifications/notifications_provider.dart';
import 'package:tiktok_clone/screens/features/onboarding/interests_screen.dart';
import 'package:tiktok_clone/screens/features/videos/views/video_recording_screen.dart';

final routerProvider = Provider((ref) {
  return GoRouter(
    initialLocation: "/home",
    redirect: (context, state) {
      final isLoggedIn = ref.read(authRepo).isLoggedIn;
      if (!isLoggedIn) {
        if (state.subloc != SignUpScreen.routeURL &&
            state.subloc != LoginScreen.routeURL) {
          return SignUpScreen.routeURL;
        }
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          ref.read(notificationsProvider(context)); // 푸시 알림 초기화
          return child;
        },
        routes: [
          GoRoute(
            name: SignUpScreen.routeName,
            path: SignUpScreen.routeURL,
            builder: (context, state) => const SignUpScreen(),
          ),
          GoRoute(
            name: LoginScreen.routeName,
            path: LoginScreen.routeURL,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            name: InterestsScreen.routeName,
            path: InterestsScreen.routeURL,
            builder: (context, state) => const InterestsScreen(),
          ),
          GoRoute(
            path: "/:tab(home|discover|inbox|profile)",
            name: MainNavigationScreen.routeName,
            builder: (context, state) {
              final tab = state.params['tab']!;
              return MainNavigationScreen(tab: tab);
            },
          ),
          GoRoute(
            name: ActivityScreen.routeName,
            path: ActivityScreen.routeURL,
            builder: (context, state) => const ActivityScreen(),
          ),
          GoRoute(
            name: ChatsScreen.routeName,
            path: ChatsScreen.routeURL,
            builder: (context, state) => const ChatsScreen(),
            routes: [
              GoRoute(
                name: ChatDetailScreen.routeName,
                path: ChatDetailScreen.routeURL,
                builder: (context, state) {
                  final chatId = state.params['chatId']!;
                  return ChatDetailScreen(chatId: chatId);
                },
              ),
            ],
          ),
          GoRoute(
            name: UserSelectionScreen.routeName,
            path: UserSelectionScreen.routeURL,
            builder: (context, state) => const UserSelectionScreen(),
          ),
          GoRoute(
            name: VideoRecordingScreen.routeName,
            path: VideoRecordingScreen.routeURL,
            pageBuilder: (context, state) => CustomTransitionPage(
              transitionDuration: Duration(milliseconds: 150),
              child: VideoRecordingScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    final position = Tween(
                      begin: Offset(0, 1),
                      end: Offset.zero,
                    ).animate(animation);
                    return SlideTransition(position: position, child: child);
                  },
            ),
          ),
        ],
      ),
    ],
  );
});
