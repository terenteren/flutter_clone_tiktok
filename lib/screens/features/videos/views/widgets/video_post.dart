import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/generated/l10n.dart';
import 'package:tiktok_clone/screens/features/videos/view_models/playback_config_vm.dart';
import 'package:tiktok_clone/screens/features/videos/views/widgets/video_button.dart';
import 'package:tiktok_clone/screens/features/videos/views/widgets/video_comments.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPost extends StatefulWidget {
  final Function onVideoFinished;
  final int index;

  const VideoPost({
    super.key,
    required this.onVideoFinished,
    required this.index,
  });

  @override
  State<VideoPost> createState() => _VideoPostState();
}

class _VideoPostState extends State<VideoPost>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  bool _isInitialized = false; // 비디오 초기화 상태
  String? _error; // 에러 메시지 저장 변수
  bool _isPaused = false;
  final Duration _animationDuration = const Duration(milliseconds: 200);
  late final AnimationController _animationController;
  late final PlaybackConfigViewModel _playbackConfigViewModel;
  late bool _localMuted; // 현재 비디오의 로컬 음소거 상태

  void _onVideoChange() {
    if (!mounted) return;
    if (!_videoPlayerController.value.isInitialized) return;

    final duration = _videoPlayerController.value.duration;
    final position = _videoPlayerController.value.position;

    // 비디오가 거의 끝났는지 확인 (100ms 여유)
    if (duration.inMilliseconds > 0 &&
        position.inMilliseconds >= duration.inMilliseconds - 100) {
      widget.onVideoFinished();
    }
  }

  void _initVideoPlayer() async {
    if (!mounted) return;

    // 로컬 음소거 상태 사용
    final isMuted = _localMuted;

    try {
      // 로컬 assets 비디오 사용
      _videoPlayerController = VideoPlayerController.asset(
        'assets/videos/video1.mp4',
      );

      await _videoPlayerController.initialize();
      await _videoPlayerController.setLooping(true);

      // 초기 음소거 설정 (웹 또는 설정값에 따라)
      await _videoPlayerController.setVolume(kIsWeb ? 0 : (isMuted ? 0 : 1.0));

      _videoPlayerController.addListener(_onVideoChange);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        // 초기 자동 재생 제거 - VisibilityDetector가 처리하도록 함
        // await _videoPlayerController.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
      debugPrint("Video initialization error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    
    // PlaybackConfigViewModel 참조를 먼저 저장
    _playbackConfigViewModel = context.read<PlaybackConfigViewModel>();
    _playbackConfigViewModel.addListener(_onPlaybackConfigChanged);
    
    // 로컬 음소거 상태를 Settings의 기본값으로 초기화
    _localMuted = _playbackConfigViewModel.muted;
    
    _initVideoPlayer();

    _animationController = AnimationController(
      vsync: this,
      lowerBound: 1.0,
      upperBound: 1.5,
      value: 1.5,
      duration: _animationDuration,
    );
  }

  @override
  void dispose() {
    // PlaybackConfigViewModel listener 제거 (저장된 참조 사용)
    _playbackConfigViewModel.removeListener(_onPlaybackConfigChanged);
    _animationController.dispose();
    _videoPlayerController.removeListener(_onVideoChange);
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _onPlaybackConfigChanged() {
    if (!mounted) return; // mounted 체크 추가
    
    // Settings가 변경되면 로컬 음소거 상태도 업데이트
    _localMuted = _playbackConfigViewModel.muted;
    
    if (_localMuted) {
      _videoPlayerController.setVolume(0);
    } else {
      if (!_isPaused && _videoPlayerController.value.isPlaying) {
        _videoPlayerController.setVolume(1.0);
      }
    }
    
    setState(() {}); // UI 업데이트
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    if (!_isInitialized) return;

    // 50% 이상 보이면 재생, 그 이하면 일시정지 및 음소거
    if (info.visibleFraction > 0.5) {
      // 사용자가 수동으로 일시정지한 경우 자동 재생하지 않음
      if (_isPaused) return;
      // 50% 이상 보일 때 자동 재생 및 로컬 음소거 상태 적용
      if (!_videoPlayerController.value.isPlaying) {
        _videoPlayerController.setVolume(_localMuted ? 0 : 1.0);

        // 자동 재생 설정이 켜져 있을 때만 재생
        final autoplay = _playbackConfigViewModel.autoplay;
        if (autoplay) {
          _videoPlayerController.play();
        }
      }
    } else {
      // 50% 미만으로 보이면 일시정지 및 음소거
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      }
      // 화면에 보이지 않을 때는 항상 음소거
      _videoPlayerController.setVolume(0);
    }

    // 화면에서 완전히 벗어났을 때 (다른 탭으로 이동 등) 상태 동기화
    if (info.visibleFraction == 0) {
      // 비디오 재생 중지 및 음소거
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      }
      _videoPlayerController.setVolume(0);
      // _isPaused 상태를 true로 업데이트하여 돌아왔을 때 자동 재생 방지
      setState(() {
        _isPaused = true;
      });
    }
  }

  void _onTogglePause() {
    if (!mounted) return;
    if (!_isInitialized) return;

    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
      _animationController.reverse(); // 애니메이션 축소
    } else {
      _videoPlayerController.play();
      _animationController.forward(); // 애니메이션 확대
    }
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _onCommentsTap(BuildContext context) async {
    if (_videoPlayerController.value.isPlaying) {
      _onTogglePause();
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => VideoComments(),
    );
    _onTogglePause();
  }

  // void _onVolumeTap() {
  //   if (!mounted) return;
  //   if (!_isInitialized) return;

  //   if (_videoPlayerController.value.volume == 0) {
  //     _videoPlayerController.setVolume(1.0);
  //   } else {
  //     _videoPlayerController.setVolume(0.0);
  //   }
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key("${widget.index}"),
      onVisibilityChanged: _onVisibilityChanged,
      child: Stack(
        children: [
          Positioned.fill(
            child: _error != null
                // 비디오 로드 실패 시 에러 메시지 표시
                ? Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Video Error',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _isInitialized
                // 비디오 초기화 완료 시 비디오 플레이어 표시
                ? VideoPlayer(_videoPlayerController)
                // 비디오 초기화 중 로딩 인디케이터 표시
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
          ),
          // 화면 터치로 재생/일시정지 토글
          Positioned.fill(child: GestureDetector(onTap: _onTogglePause)),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animationController.value,
                      child: child,
                    );
                  },
                  child: AnimatedOpacity(
                    opacity: _isPaused ? 1 : 0,
                    duration: _animationDuration,
                    child: FaIcon(
                      FontAwesomeIcons.play,
                      color: Colors.white,
                      size: Sizes.size52,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 30,
            top: 60,
            child: IconButton(
              icon: FaIcon(
                _localMuted
                    ? FontAwesomeIcons.volumeOff
                    : FontAwesomeIcons.volumeHigh,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _localMuted = !_localMuted;
                  _videoPlayerController.setVolume(_localMuted ? 0 : 1.0);
                });
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@키프트",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Sizes.size20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gaps.v10,
                Text(
                  "This is my first video",
                  style: TextStyle(color: Colors.white, fontSize: Sizes.size12),
                ),
              ],
            ),
          ),
          // Positioned(
          //   top: 90,
          //   right: 30,
          //   child: Column(
          //     children: [
          //       GestureDetector(
          //         onTap: () => _onVolumeTap(),
          //         child: VideoButton(
          //           icon: _videoPlayerController.value.volume == 0
          //               ? FontAwesomeIcons.volumeXmark
          //               : FontAwesomeIcons.volumeOff,
          //           text: "",
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  foregroundImage: NetworkImage(
                    "https://avatars.githubusercontent.com/u/33644179?v=4",
                  ),
                  child: Text("키프트"),
                ),
                Gaps.v24,
                VideoButton(
                  icon: FontAwesomeIcons.solidHeart,
                  text: S.of(context).likeCount(123123),
                ),
                Gaps.v24,
                GestureDetector(
                  onTap: () => _onCommentsTap(context),
                  child: VideoButton(
                    icon: FontAwesomeIcons.solidComment,
                    text: S.of(context).commentCount(123123),
                  ),
                ),
                Gaps.v24,
                VideoButton(icon: FontAwesomeIcons.share, text: "Share"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
