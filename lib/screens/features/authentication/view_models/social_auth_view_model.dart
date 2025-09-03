import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok_clone/utils.dart';

class SocialAuthViewModel extends AsyncNotifier<void> {
  late final AuthenticationRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(authRepo);
  }

  Future<void> githubSignIn(BuildContext context) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        print("GitHub Sign-In 시도 중...");
        await _repository.githubSignIn();
        print("GitHub Sign-In 성공!");
      },
    );
    if (state.hasError) {
      print("GitHub Sign-In 오류: ${state.error}");
      showFirebaseErrorSnack(context, state.error);
    } else {
      // 성공 시 홈 탭으로 이동
      context.go("/home");  // 이것은 /:tab 라우트의 home 탭으로 매칭됨
    }
  }
}

final socialAuthProvider = AsyncNotifierProvider<SocialAuthViewModel, void>(
  () => SocialAuthViewModel(),
);
