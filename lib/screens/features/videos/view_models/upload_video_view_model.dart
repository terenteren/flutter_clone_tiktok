import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_Repo.dart';
import 'package:tiktok_clone/screens/features/users/view_models/users_view_model.dart';
import 'package:tiktok_clone/screens/features/videos/models/video_model.dart';
import 'package:tiktok_clone/screens/features/videos/repos/videos_repo.dart';

class UploadVideoViewModel extends AsyncNotifier<void> {
  late final VideosRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(videosRepo);
  }

  Future<void> uploadVideo(File video, BuildContext context) async {
    final user = ref.read(authRepo).user;
    final userProfile = ref.read(usersProvider).value;
    
    if (userProfile != null && user != null) {
      state = const AsyncValue.loading();
      
      try {
        // 먼저 비디오 검증 수행
        final validationResult = await _repository.validateVideo(video);
        
        if (!validationResult['isValid']) {
          // 검증 실패 시 에러 표시
          state = AsyncValue.error(
            validationResult['error'],
            StackTrace.current,
          );
          
          // 사용자에게 에러 메시지 표시
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(validationResult['error']),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }
        
        // 검증 통과 시 업로드 진행
        state = await AsyncValue.guard(() async {
          final task = await _repository.uploadVideoFile(video, user.uid);
          if (task != null) {
            final snapshot = await task;
            final downloadUrl = await snapshot.ref.getDownloadURL();
            
            await _repository.saveVideo(
              VideoModel(
                title: "My Video",
                description: "This is my video",
                fileUrl: downloadUrl,
                thumbnailUrl: "",
                creatorUid: user.uid,
                creator: userProfile.name,
                likes: 0,
                comments: 0,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
            
            // 업로드 성공 메시지
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('비디오가 성공적으로 업로드되었습니다!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              context.pop();
              context.pop();
            }
          }
        });
      } catch (e) {
        // 예상치 못한 에러 처리
        state = AsyncValue.error(e, StackTrace.current);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('업로드 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}

final uploadVideoProvider = AsyncNotifierProvider<UploadVideoViewModel, void>(
  () => UploadVideoViewModel(),
);
