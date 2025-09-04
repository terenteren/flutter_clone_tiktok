import { setGlobalOptions } from "firebase-functions/v2";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

// Firebase Admin SDK 초기화
admin.initializeApp();

// 전역 설정: 동시 실행 가능한 컨테이너 수 제한 (비용 관리)
setGlobalOptions({ maxInstances: 10 });

/**
 * Firebase Cloud Function: onVideoCreated
 * 
 * 트리거: Firestore 'videos' 컬렉션에 새 문서 생성 시 자동 실행
 * 목적: 업로드된 비디오의 썸네일을 자동 생성하고 Firestore/Storage에 저장
 * 
 * 실행 순서:
 * 1. 비디오 문서 생성 이벤트 감지
 * 2. 비디오 데이터 유효성 검증
 * 3. FFmpeg로 1초 지점 프레임 추출 (150px 너비)
 * 4. Storage에 썸네일 업로드 (thumbnails/ 폴더)
 * 5. Firestore 업데이트:
 *    - videos 컬렉션 문서 업데이트
 *    - users/{uid}/videos 서브컬렉션에 썸네일 정보 저장
 * 6. 임시 파일 정리
 */
export const onVideoCreated = onDocumentCreated(
  {
    document: "videos/{videoId}",    // 트리거 경로
    region: "asia-northeast3",       // 리전: 도쿄 (한국 인접)
    memory: "1GiB",                  // 메모리: FFmpeg 처리용
    timeoutSeconds: 120,             // 타임아웃: 2분
  },
  async (event) => {
    // Step 1: 이벤트 데이터 검증
    const snapshot = event.data;
    if (!snapshot) {
      logger.log("No data associated with the event");
      return;
    }

    // Step 2: 비디오 데이터 추출
    const video = snapshot.data();
    const videoId = event.params.videoId;
    
    logger.log(`Video created with ID: ${videoId}`, video);

    // Step 3: 필수 필드 검증 (fileUrl, creatorUid)
    if (!video.fileUrl) {
      logger.log("No video URL found");
      return;
    }
    
    if (!video.creatorUid) {
      logger.log("No creator UID found");
      return;
    }

    try {
      logger.log(`Processing video: ${videoId}`);

      // Step 4: FFmpeg로 썸네일 생성 준비
      const spawn = require("child-process-promise").spawn;
      const fs = require("fs").promises;
      const tempFilePath = `/tmp/${videoId}.jpg`;
      
      // Step 5: FFmpeg 실행 - 1초 지점 프레임 추출
      await spawn("ffmpeg", [
        "-i", video.fileUrl,           // 입력: 비디오 URL
        "-ss", "00:00:01.000",          // 시간: 1초 지점
        "-vframes", "1",                // 프레임: 1개만 추출
        "-vf", "scale=150:-1",          // 필터: 너비 150px (높이 자동)
        tempFilePath                    // 출력: 임시 파일
      ]);
      
      logger.log(`Thumbnail created at ${tempFilePath}`);
      
      // Step 6: Firebase Storage에 썸네일 업로드
      const bucket = admin.storage().bucket();
      const [file] = await bucket.upload(tempFilePath, {
        destination: `thumbnails/${videoId}.jpg`,
        metadata: {
          contentType: "image/jpeg",
        },
      });
      
      // Step 7: 업로드된 파일 공개 설정 및 URL 생성
      await file.makePublic();
      const thumbnailUrl = file.publicUrl();
      
      logger.log(`Thumbnail uploaded to Storage: thumbnails/${videoId}.jpg`);
      
      // Step 8: 임시 파일 삭제 (서버 디스크 공간 관리)
      await fs.unlink(tempFilePath);

      // Step 9: Firestore 업데이트
      const db = admin.firestore();
      
      // 9-1: 메인 비디오 문서 업데이트 (videos 컬렉션)
      await db.collection("videos").doc(videoId).update({
        thumbnailUrl: thumbnailUrl,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      // 9-2: 사용자 프로필용 서브컬렉션 생성 (users/{uid}/videos)
      await db
        .collection("users")
        .doc(video.creatorUid)
        .collection("videos")
        .doc(videoId)
        .set({
          thumbnailUrl: thumbnailUrl,
          videoId: videoId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      logger.log(`Successfully processed video ${videoId}: thumbnail created and documents updated`);
    } catch (error) {
      // Step 10: 에러 처리
      logger.error(`Error processing video ${videoId}:`, error);
      
      // Firestore에 에러 상태 기록 (선택적)
      try {
        await admin.firestore().collection("videos").doc(videoId).update({
          thumbnailError: true,
          errorMessage: error instanceof Error ? error.message : "Unknown error",
          errorTimestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (updateError) {
        logger.error("Failed to update error status:", updateError);
      }
      
      // 에러를 상위로 전파 (Cloud Functions 콘솔에서 확인 가능)
      throw error;
    }
  }
);
