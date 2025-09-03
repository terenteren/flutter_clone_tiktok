import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/videos/models/playback_config_model.dart';
import 'package:tiktok_clone/screens/features/videos/repos/video_playback_config_repo.dart';

class PlaybackConfigViewModel extends Notifier<PlaybackConfigModel> {
  late VideoPlaybackConfigRepository _repository;

  @override
  PlaybackConfigModel build() {
    _repository = ref.read(videoPlaybackConfigRepoProvider);

    return PlaybackConfigModel(
      muted: _repository.isMuted(),
      autoplay: _repository.isAutoplay(),
    );
  }

  void setMuted(bool value) {
    _repository.setMuted(value);
    state = PlaybackConfigModel(muted: value, autoplay: state.autoplay);
  }

  void setAutoplay(bool value) {
    _repository.setAutoplay(value);
    state = PlaybackConfigModel(muted: state.muted, autoplay: value);
  }
}

// Provider 정의
final playbackConfigProvider =
    NotifierProvider<PlaybackConfigViewModel, PlaybackConfigModel>(
      () => PlaybackConfigViewModel(),
    );

// Repository Provider
final videoPlaybackConfigRepoProvider = Provider<VideoPlaybackConfigRepository>(
  (ref) {
    throw UnimplementedError(
      'VideoPlaybackConfigRepository must be overridden',
    );
  },
);
