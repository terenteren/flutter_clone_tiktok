import 'package:shared_preferences/shared_preferences.dart';

class VideoPlaybackConfigRepository {
  static const String _autoplay = "autoplay";
  static const String _muted = "muted";

  final SharedPreferences _preferences;

  VideoPlaybackConfigRepository(this._preferences);

  Future<void> setMuted(bool value) async {
    await _preferences.setBool(_muted, value);
  }

  Future<void> setAutoplay(bool value) async {
    await _preferences.setBool(_autoplay, value);
  }

  // 음소거 설정이 활성화되어 있으면 true, 그렇지 않으면 false.
  // 기본값: false (토글 OFF - 소리 켜짐)
  bool isMuted() {
    return _preferences.getBool(_muted) ?? false;
  }

  // 자동 재생 설정이 활성화되어 있으면 true, 그렇지 않으면 false.
  // 기본값: false (토글 OFF - 자동 재생 안함)
  bool isAutoplay() {
    return _preferences.getBool(_autoplay) ?? false;
  }
}
