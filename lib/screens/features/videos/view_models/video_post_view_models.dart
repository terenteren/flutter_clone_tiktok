import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok_clone/screens/features/videos/repos/videos_repo.dart';

class VideoPostViewModel extends FamilyAsyncNotifier<bool, String> {
  late final VideosRepository _repository;
  late final String videoId;
  late final String _userId;
  bool _isLiked = false;

  @override
  FutureOr<bool> build(String videoId) async {
    this.videoId = videoId;
    _repository = ref.read(videosRepo);
    final user = ref.read(authRepo).user;
    _userId = user!.uid;
    
    // 좋아요 상태 확인
    _isLiked = await _repository.isLiked(videoId, _userId);
    return _isLiked;
  }

  Future<bool> toggleLike() async {
    // 즉시 UI 업데이트를 위한 로컬 상태 변경
    _isLiked = !_isLiked;
    state = AsyncValue.data(_isLiked);
    
    // Firestore 업데이트 (Cloud Functions가 카운트 업데이트)
    await _repository.togglelikeVideo(videoId, _userId);
    
    return _isLiked;
  }
  
  // 실시간 좋아요 수 스트림
  Stream<int> getLikesStream() {
    return _repository.getLikesStream(videoId);
  }
}

final videoPostProvider =
    AsyncNotifierProvider.family<VideoPostViewModel, bool, String>(
      () => VideoPostViewModel(),
    );

// 실시간 좋아요 수 Provider
final videoLikesProvider = StreamProvider.family<int, String>((ref, videoId) {
  final repository = ref.watch(videosRepo);
  return repository.getLikesStream(videoId);
});