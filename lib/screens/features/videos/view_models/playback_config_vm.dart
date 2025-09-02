import 'package:flutter/foundation.dart';
import 'package:tiktok_clone/screens/features/videos/models/playback_config_model.dart';
import 'package:tiktok_clone/screens/features/videos/repos/video_playback_config_repo.dart';

class PlaybackConfigViewModel extends ChangeNotifier {
  final VideoPlaybackConfigRepository? _repository;

  late final PlaybackConfigModel _model;

  PlaybackConfigViewModel(VideoPlaybackConfigRepository repository)
    : _repository = repository,
      _model = PlaybackConfigModel(
        muted: repository.isMuted(),
        autoplay: repository.isAutoplay(),
      );

  PlaybackConfigViewModel.withoutRepository()
    : _repository = null,
      _model = PlaybackConfigModel(muted: false, autoplay: false);

  bool get muted => _model.muted;

  bool get autoplay => _model.autoplay;

  void setMuted(bool value) {
    _repository?.setMuted(value); // null-safe 호출
    _model.muted = value;
    notifyListeners();
  }

  void setAutoplay(bool value) {
    _repository?.setAutoplay(value); // null-safe 호출
    _model.autoplay = value;
    notifyListeners();
  }
}
