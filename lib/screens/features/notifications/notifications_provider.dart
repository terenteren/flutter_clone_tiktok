import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_Repo.dart';
import 'package:tiktok_clone/screens/features/inbox/chats_screen.dart';
import 'package:tiktok_clone/screens/features/videos/views/video_recording_screen.dart';

class NotificationsProvider extends FamilyAsyncNotifier<void, BuildContext> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> updateToken(String token) async {
    final user = ref.read(authRepo).user;
    if (user == null) {
      if (kDebugMode) {
        print('User is null, cannot update token');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('Updating token for user: ${user.uid}');
      }

      String platform = "web";
      if (!kIsWeb) {
        platform = Platform.isIOS ? "ios" : "android";
      }
      
      await _db.collection("users").doc(user.uid).set({
        "token": token,
        "platform": platform,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('Token successfully updated in Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating token: $e');
      }
    }
  }

  Future<void> initListeners(BuildContext context) async {
    // 권한 요청
    final permission = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (permission.authorizationStatus == AuthorizationStatus.denied) {
      if (kDebugMode) {
        print('User denied notification permission');
      }
      return;
    }

    if (kDebugMode) {
      print('User granted permission: ${permission.authorizationStatus}');
    }

    // Foreground 메시지 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      if (kDebugMode) {
        print("I just got a message and I'm in the foreground");
        print('Title: ${event.notification?.title}');
        print('Body: ${event.notification?.body}');
        print('Data: ${event.data}');
      }

      if (event.notification != null) {
        // 여기서 로컬 알림을 표시하거나 UI 업데이트 가능
        // TODO: flutter_local_notifications 패키지로 로컬 알림 표시
      }
    });

    // Background 메시지 처리
    FirebaseMessaging.onMessageOpenedApp.listen((notification) {
      context.pushNamed(ChatsScreen.routeName);
    });

    // Terminated 상태에서 메시지 처리
    final notification = await _messaging.getInitialMessage();
    if (notification != null) {
      context.pushNamed(VideoRecordingScreen.routeName);
    }

    // 앱이 백그라운드 상태에서 알림을 탭했을 때
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // 앱이 종료된 상태에서 알림을 탭하여 앱을 열었을 때
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // 토큰 갱신 리스너
    _messaging.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print('FCM Token refreshed: $newToken');
      }
      await updateToken(newToken);
    });
  }

  void _handleMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Handling a message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }
    // 여기서 메시지 데이터에 따라 특정 화면으로 네비게이션 가능
  }

  @override
  Future<void> build(BuildContext context) async {
    // 사용자 로그인 상태 확인
    final user = ref.read(authRepo).user;
    if (user == null) {
      if (kDebugMode) {
        print('User not logged in, skipping notification setup');
      }
      return;
    }

    if (kDebugMode) {
      print('Setting up notifications for user: ${user.uid}');
    }

    // 모든 리스너 초기화
    await initListeners(context);

    // FCM 토큰 가져오기 및 저장
    try {
      // iOS의 경우 APNs 토큰이 필요할 수 있음 (Web에서는 스킵)
      bool isIOS = false;
      if (!kIsWeb) {
        try {
          isIOS = Platform.isIOS;
        } catch (e) {
          // Platform 체크 실패 시 무시
        }
      }
      
      if (isIOS) {
        final apnsToken = await _messaging.getAPNSToken().timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        );
        if (kDebugMode) {
          print('APNs Token: $apnsToken');
        }
      }

      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      if (token != null) {
        if (kDebugMode) {
          print('FCM Token: $token');
        }
        await updateToken(token);
      } else {
        if (kDebugMode) {
          print('FCM Token is null');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
    }
  }
}

final notificationsProvider = AsyncNotifierProvider.family(
  () => NotificationsProvider(),
);
