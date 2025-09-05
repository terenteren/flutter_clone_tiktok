import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/videos/models/video_model.dart';
import 'package:video_player/video_player.dart';

class VideosRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 비디오 제한 설정
  static const int maxVideoDurationSeconds = 20; // 20초 제한
  static const int maxVideoSizeMB = 50; // 50MB 제한 (일반적인 20초 영상 크기)

  // 비디오 검증 메서드
  Future<Map<String, dynamic>> validateVideo(File video) async {
    try {
      // 1. 파일 크기 확인
      final fileSizeInBytes = await video.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > maxVideoSizeMB) {
        return {
          'isValid': false,
          'error': '비디오 파일 크기가 너무 큽니다. 최대 ${maxVideoSizeMB}MB까지 업로드 가능합니다.',
          'fileSize': fileSizeInMB,
        };
      }

      // 2. 비디오 길이 확인
      final videoController = VideoPlayerController.file(video);
      await videoController.initialize();

      final duration = videoController.value.duration;
      final durationInSeconds = duration.inSeconds;

      // 컨트롤러 정리
      await videoController.dispose();

      if (durationInSeconds > maxVideoDurationSeconds) {
        return {
          'isValid': false,
          'error': '비디오 길이는 최대 ${maxVideoDurationSeconds}초까지만 가능합니다.',
          'duration': durationInSeconds,
        };
      }

      // 3. 검증 통과
      return {
        'isValid': true,
        'fileSize': fileSizeInMB,
        'duration': durationInSeconds,
      };
    } catch (e) {
      return {'isValid': false, 'error': '비디오 파일을 확인하는 중 오류가 발생했습니다: $e'};
    }
  }

  // upload a video file (검증 포함)
  Future<UploadTask?> uploadVideoFile(File video, String uid) async {
    // 비디오 검증
    final validationResult = await validateVideo(video);

    if (!validationResult['isValid']) {
      throw Exception(validationResult['error']);
    }

    final fileRef = _storage.ref().child(
      "/videos/$uid/${DateTime.now().millisecondsSinceEpoch.toString()}",
    );
    return fileRef.putFile(video);
  }

  // create a video document
  Future<void> saveVideo(VideoModel data) async {
    await _db.collection("videos").add(data.toJson());
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchVideos({
    int? lastItemCreatedAt,
  }) {
    final query = _db
        .collection("videos")
        .orderBy("createdAt", descending: true)
        .limit(2);
    if (lastItemCreatedAt == null) {
      return query.get();
    } else {
      return query.startAfter([lastItemCreatedAt]).get();
    }
  }

  Future<void> togglelikeVideo(String videoId, String userId) async {
    final query = _db.collection("likes").doc("${videoId}000$userId");
    final like = await query.get();

    if (!like.exists) {
      // 좋아요 추가 (Cloud Functions가 카운트 업데이트)
      await query.set({"createdAt": DateTime.now().millisecondsSinceEpoch});
    } else {
      // 좋아요 삭제 (Cloud Functions가 카운트 업데이트)
      await query.delete();
    }
  }
  
  Future<bool> isLiked(String videoId, String userId) async {
    final doc = await _db.collection("likes").doc("${videoId}000$userId").get();
    return doc.exists;
  }
  
  // 실시간 좋아요 수 스트림
  Stream<int> getLikesStream(String videoId) {
    return _db.collection("videos").doc(videoId).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data?['likes'] ?? 0;
    });
  }
}

final videosRepo = Provider((ref) => VideosRepository());
