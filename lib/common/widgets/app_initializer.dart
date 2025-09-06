import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok_clone/screens/features/notifications/notifications_provider.dart';

class AppInitializer extends ConsumerStatefulWidget {
  final Widget child;
  
  const AppInitializer({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 약간의 지연을 주어 앱이 완전히 시작되도록 함
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 사용자가 로그인되어 있는지 확인
    final user = ref.read(authRepo).user;
    if (user != null && mounted) {
      try {
        // notifications provider 초기화
        await ref.read(notificationsProvider.future);
      } catch (e) {
        // 에러가 발생해도 앱은 계속 실행
        debugPrint('Failed to initialize notifications: $e');
      }
    }
    
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}