import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/generated/l10n.dart';
import 'package:tiktok_clone/screens/features/videos/models/video_model.dart';
import 'package:tiktok_clone/screens/features/videos/view_models/playback_config_vm.dart';
import 'package:tiktok_clone/screens/features/videos/view_models/video_post_view_models.dart';
import 'package:tiktok_clone/screens/features/videos/views/widgets/video_button.dart';
import 'package:tiktok_clone/screens/features/videos/views/widgets/video_comments.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPost extends ConsumerStatefulWidget {
  final Function onVideoFinished;
  final VideoModel videoData;
  final int index;

  const VideoPost({
    super.key,
    required this.videoData,
    required this.onVideoFinished,
    required this.index,
  });

  @override
  ConsumerState<VideoPost> createState() => _VideoPostState();
}

class _VideoPostState extends ConsumerState<VideoPost>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  bool _isInitialized = false; // 비디오 초기화 상태
  String? _error; // 에러 메시지 저장 변수
  bool _isManuallyPaused = false; // 사용자가 수동으로 일시정지했는지 추적
  final Duration _animationDuration = const Duration(milliseconds: 200);
  late final AnimationController _animationController;
  late bool _localMuted; // 현재 비디오의 로컬 음소거 상태
  int _likeCount = 0; // 좋아요 수 로컬 상태

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

  void _onLikeTap() async {
    await ref
        .read(videoPostProvider(widget.videoData.id).notifier)
        .toggleLike();
  }

  void _initVideoPlayer() async {
    if (!mounted) return;

    // 로컬 음소거 상태 사용
    final isMuted = _localMuted;

    try {
      // Firebase Storage의 비디오 URL 사용
      _videoPlayerController = VideoPlayerController.network(
        widget.videoData.fileUrl,
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

        // 비디오 초기화 후 자동재생 설정 확인
        final autoplay = ref.read(playbackConfigProvider).autoplay;
        if (autoplay && !_isManuallyPaused) {
          await _videoPlayerController.play();
        }
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

    // 로컬 음소거 상태를 Settings의 기본값으로 초기화
    _localMuted = ref.read(playbackConfigProvider).muted;
    
    // 좋아요 수 초기화
    _likeCount = widget.videoData.likes;

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
    _animationController.dispose();
    _videoPlayerController.removeListener(_onVideoChange);
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    if (!_isInitialized) return;

    // 50% 이상 보이면 재생, 그 이하면 일시정지 및 음소거
    if (info.visibleFraction > 0.5) {
      // 50% 이상 보일 때 자동 재생 및 로컬 음소거 상태 적용
      if (!_videoPlayerController.value.isPlaying) {
        _videoPlayerController.setVolume(_localMuted ? 0 : 1.0);

        // 자동 재생 설정이 켜져 있을 때만 재생
        // 사용자가 수동으로 일시정지한 경우는 자동 재생하지 않음
        final autoplay = ref.read(playbackConfigProvider).autoplay;
        if (autoplay && !_isManuallyPaused) {
          _videoPlayerController.play();
        }
      }
    } else {
      // 50% 미만으로 보이면 일시정지 및 음소거
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
        // 자동으로 일시정지되었으므로 _isManuallyPaused는 변경하지 않음
      }
      // 화면에 보이지 않을 때는 항상 음소거
      _videoPlayerController.setVolume(0);

      // 화면에서 완전히 벗어났을 때 수동 일시정지 상태 초기화
      if (info.visibleFraction == 0) {
        setState(() {
          _isManuallyPaused = false;
        });
      }
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
      _isManuallyPaused = !_videoPlayerController.value.isPlaying;
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
    // Settings의 음소거 상태를 감지하고 로컬 상태 업데이트
    ref.listen(playbackConfigProvider, (previous, next) {
      if (!mounted) return;
      if (previous?.muted != next.muted) {
        setState(() {
          _localMuted = next.muted;
          _videoPlayerController.setVolume(_localMuted ? 0 : 1.0);
        });
      }
    });

    return VisibilityDetector(
      key: Key("${widget.index}"),
      onVisibilityChanged: _onVisibilityChanged,
      child: Stack(
        children: [
          Positioned.fill(
            child: _videoPlayerController.value.isInitialized
                ? VideoPlayer(_videoPlayerController)
                : Image.network(
                    widget.videoData.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
          ),
          // 화면 터치로 재생/일시정지 토글
          Positioned.fill(child: GestureDetector(onTap: _onTogglePause)),
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
                  "@${widget.videoData.creator}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Sizes.size20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gaps.v10,
                Text(
                  widget.videoData.description,
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
                    "https://firebasestorage.googleapis.com/v0/b/kift-tiktok-clone-v1.firebasestorage.app/o/avatars%2F${widget.videoData.creatorUid}?alt=media",
                  ),
                  child: Text(widget.videoData.creator),
                ),
                Gaps.v24,
                GestureDetector(
                  onTap: _onLikeTap,
                  child: ref.watch(videoPostProvider(widget.videoData.id)).when(
                    loading: () => VideoButton(
                      icon: FontAwesomeIcons.heart,
                      text: S.of(context).likeCount(widget.videoData.likes),
                    ),
                    error: (error, stack) => VideoButton(
                      icon: FontAwesomeIcons.heart,
                      text: S.of(context).likeCount(widget.videoData.likes),
                    ),
                    data: (isLiked) {
                      // 실시간 좋아요 수 가져오기
                      final likesAsync = ref.watch(videoLikesProvider(widget.videoData.id));
                      final likeCount = likesAsync.when(
                        data: (count) => count,
                        loading: () => _likeCount,
                        error: (_, __) => _likeCount,
                      );
                      
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: VideoButton(
                          key: ValueKey(isLiked),
                          icon: isLiked 
                              ? FontAwesomeIcons.solidHeart 
                              : FontAwesomeIcons.heart,
                          text: S.of(context).likeCount(likeCount),
                          iconColor: isLiked ? Colors.red : Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                Gaps.v24,
                GestureDetector(
                  onTap: () => _onCommentsTap(context),
                  child: VideoButton(
                    icon: FontAwesomeIcons.solidComment,
                    text: S.of(context).commentCount(widget.videoData.comments),
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
