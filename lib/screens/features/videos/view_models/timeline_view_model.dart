import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/videos/models/video_model.dart';
import 'package:tiktok_clone/screens/features/videos/repos/videos_repo.dart';

class TimelineViewModel extends AsyncNotifier<List<VideoModel>> {
  late final VideosRepository _repository;
  List<VideoModel> _list = [];

  /// 비디오 목록 가져오기
  Future<List<VideoModel>> _fetchVideos({int? lastItemCreatedAt}) async {
    final result = await _repository.fetchVideos(
      lastItemCreatedAt: lastItemCreatedAt, // 파라미터를 실제로 전달
    );
    final videos = result.docs.map(
      (doc) => VideoModel.fromJson(json: doc.data(), videoId: doc.id),
    ); // Firestore 문서를 VideoModel로 변환
    return videos.toList();
  }

  @override
  FutureOr<List<VideoModel>> build() async {
    _repository = ref.read(videosRepo); // repository 주입

    _list = await _fetchVideos(lastItemCreatedAt: null); // 초기 데이터 로드
    return _list;
  }

  /// 페이징 처리 - 다음 페이지 가져오기
  Future<void> fetchNextPage() async {
    final nextPage = await _fetchVideos(
      lastItemCreatedAt: _list.last.createdAt,
    );
    _list = [..._list, ...nextPage]; // _list 업데이트
    state = AsyncValue.data(_list);
  }

  /// 비디오 목록 새로고침
  Future<void> refresh() async {
    final videos = await _fetchVideos(lastItemCreatedAt: null);
    _list = videos;
    state = AsyncValue.data(_list);
  }
}

final timelineProvider =
    AsyncNotifierProvider<TimelineViewModel, List<VideoModel>>(
      () => TimelineViewModel(),
    );
