import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/screens/features/videos/views/video_preview_screen.dart';

class VideoRecordingScreen extends StatefulWidget {
  static const String routeName = "postVideo";
  static const String routeURL = "/upload";
  const VideoRecordingScreen({super.key});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _hasPermissions = false;

  bool _isSelfieMode = false;

  late final bool _noCamera = kDebugMode && Platform.isIOS;

  late final AnimationController _buttonAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );

  late final Animation<double> _buttonAnimation = Tween(
    begin: 1.0,
    end: 1.3,
  ).animate(_buttonAnimationController);

  late final AnimationController _progressAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10),
        lowerBound: 0.0,
        upperBound: 1.0,
      );

  // late final Animation<double> _progressAnimation = Tween(
  //   begin: 0.0,
  //   end: 1.0,
  // ).animate(_progressAnimationController);

  late FlashMode _flashMode;

  late CameraController _cameraController;

  Future<void> initCamera() async {
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      // print("No camera available");
      return;
    }

    _cameraController = CameraController(
      cameras[_isSelfieMode ? 1 : 0], // 카메라 (0: 후면, 1: 전면)
      ResolutionPreset.ultraHigh, // 카메라 해상도 설정
      enableAudio: true, // 오디오 사용 여부
    );

    await _cameraController.initialize(); // 카메라 초기화

    await _cameraController
        .prepareForVideoRecording(); // 비디오 녹화 준비 (오직 IOS에서만 필요)

    _flashMode = _cameraController.value.flashMode;

    setState(() {});
  }

  void initPermissions() async {
    final cameraPermission = await Permission.camera.request();
    final micPermission = await Permission.microphone.request();

    final cameraDenied =
        cameraPermission.isDenied || cameraPermission.isPermanentlyDenied;

    final micDenied =
        micPermission.isDenied || micPermission.isPermanentlyDenied;

    if (!cameraDenied && !micDenied) {
      _hasPermissions = true;
      await initCamera();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    if (!_noCamera) {
      initPermissions();
    } else {
      setState(() {
        _hasPermissions = true;
      });
    }
    WidgetsBinding.instance.addObserver(this);
    _progressAnimationController.addListener(() {
      setState(() {});
    });
    _progressAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopRecording();
      }
    });
  }

  Future<void> _toggleSelfiMode() async {
    _isSelfieMode = !_isSelfieMode;
    await initCamera();
    setState(() {});
  }

  Future<void> _setFlashMode(FlashMode newFlashMode) async {
    await _cameraController.setFlashMode(newFlashMode);
    _flashMode = newFlashMode;
    setState(() {});
  }

  Future<void> _startRecording(TapDownDetails _) async {
    if (_cameraController.value.isRecordingVideo) return;

    await _cameraController.startVideoRecording();

    _buttonAnimationController.forward();
    _progressAnimationController.forward();
  }

  Future<void> _stopRecording() async {
    if (!_cameraController.value.isRecordingVideo) return;

    _buttonAnimationController.reverse();
    _progressAnimationController.reset();

    final video = await _cameraController.stopVideoRecording();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPreviewScreen(video: video, isPicked: false),
      ),
    );
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _buttonAnimationController.dispose();
    if (!_noCamera) {
      _cameraController.dispose();
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_noCamera) return;
    if (!_hasPermissions) return;
    if (!_cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  Future<void> _onPickVideoPresse() async {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (video == null) return;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPreviewScreen(video: video, isPicked: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: !_hasPermissions
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Initializing...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Sizes.size20,
                    ),
                  ),
                  Gaps.v20,
                  CircularProgressIndicator.adaptive(),
                ],
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  if (!_noCamera && _cameraController.value.isInitialized)
                    CameraPreview(_cameraController),
                  Positioned(
                    top: Sizes.size64,
                    left: Sizes.size20,
                    child: CloseButton(color: Colors.white),
                  ),
                  if (!_noCamera)
                    Positioned(
                      top: Sizes.size64,
                      right: Sizes.size20,
                      child: Column(
                        children: [
                          IconButton(
                            color: Colors.white,
                            onPressed: _toggleSelfiMode,
                            icon: Icon(
                              Icons.cameraswitch,
                              // color: Colors.white,
                              size: Sizes.size40,
                            ),
                          ),
                          Gaps.v10,
                          IconButton(
                            color: _flashMode == FlashMode.off
                                ? Colors.amber.shade200
                                : Colors.white,
                            onPressed: () => _setFlashMode(FlashMode.off),
                            icon: Icon(
                              Icons.flash_off_rounded,
                              size: Sizes.size40,
                            ),
                          ),
                          Gaps.v10,
                          IconButton(
                            color: _flashMode == FlashMode.always
                                ? Colors.amber.shade200
                                : Colors.white,
                            onPressed: () => _setFlashMode(FlashMode.always),
                            icon: Icon(
                              Icons.flash_on_rounded,
                              size: Sizes.size40,
                            ),
                          ),
                          Gaps.v10,
                          IconButton(
                            color: _flashMode == FlashMode.auto
                                ? Colors.amber.shade200
                                : Colors.white,
                            onPressed: () => _setFlashMode(FlashMode.auto),
                            icon: Icon(
                              Icons.flash_auto_rounded,
                              size: Sizes.size40,
                            ),
                          ),
                          Gaps.v10,
                          IconButton(
                            color: _flashMode == FlashMode.torch
                                ? Colors.amber.shade200
                                : Colors.white,
                            onPressed: () => _setFlashMode(FlashMode.torch),
                            icon: Icon(
                              Icons.flashlight_on_rounded,
                              size: Sizes.size40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    bottom: Sizes.size40,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Spacer(),
                        GestureDetector(
                          onTapDown: _startRecording,
                          onTapUp: (details) => _stopRecording(),
                          child: ScaleTransition(
                            scale: _buttonAnimation,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: Sizes.size96,
                                  height: Sizes.size96,
                                  child: CircularProgressIndicator(
                                    color: Colors.red.shade400,
                                    strokeWidth: Sizes.size6,
                                    value: _progressAnimationController.value,
                                  ),
                                ),
                                Container(
                                  width: Sizes.size80,
                                  height: Sizes.size80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: IconButton(
                              onPressed: _onPickVideoPresse,
                              icon: FaIcon(
                                FontAwesomeIcons.image,
                                color: Colors.white,
                                size: Sizes.size40,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
