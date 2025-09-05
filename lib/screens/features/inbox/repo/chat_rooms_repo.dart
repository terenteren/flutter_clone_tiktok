import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/inbox/models/chat_room_model.dart';

class ChatRoomsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createChatRoom({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) async {
    try {
      // 채팅방 ID 생성 (두 사용자 ID를 정렬해서 조합)
      final List<String> userIds = [currentUserId, otherUserId]..sort();
      final chatRoomId = userIds.join('_');

      // 이미 존재하는 채팅방인지 확인
      final existingRoom = await _db.collection('chat_rooms').doc(chatRoomId).get();
      
      if (!existingRoom.exists) {
        // 새 채팅방 생성 - 양쪽 사용자 모두가 볼 수 있도록
        final roomData = {
          'personA': userIds[0], // 정렬된 첫 번째 ID
          'personB': userIds[1], // 정렬된 두 번째 ID
          'personAName': userIds[0] == currentUserId ? currentUserName : otherUserName,
          'personBName': userIds[1] == currentUserId ? currentUserName : otherUserName,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'participants': [currentUserId, otherUserId], // 참가자 배열 추가
          'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        };
        
        await _db.collection('chat_rooms').doc(chatRoomId).set(roomData);
      } else {
        // 채팅방이 이미 존재하면 마지막 메시지 시간만 업데이트
        await _db.collection('chat_rooms').doc(chatRoomId).update({
          'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        });
      }

      return chatRoomId;
    } catch (e) {
      throw Exception('채팅방 생성 실패: $e');
    }
  }

  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    // participants 배열을 사용하여 쿼리 (인덱스 불필요)
    return _db
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      // ChatRoomModel로 변환
      final chatRooms = snapshot.docs.map((doc) {
        return ChatRoomModel.fromJson(
          json: doc.data(),
          chatRoomId: doc.id,
        );
      }).toList();
      
      // 클라이언트 측에서 정렬 (lastMessageTime 기준)
      chatRooms.sort((a, b) {
        final aTime = a.lastMessageTime?.millisecondsSinceEpoch ?? 
                      a.createdAt.millisecondsSinceEpoch;
        final bTime = b.lastMessageTime?.millisecondsSinceEpoch ?? 
                      b.createdAt.millisecondsSinceEpoch;
        return bTime.compareTo(aTime);
      });
      
      return chatRooms;
    });
  }

  Future<ChatRoomModel?> getChatRoom(String chatRoomId) async {
    final doc = await _db.collection('chat_rooms').doc(chatRoomId).get();
    
    if (!doc.exists) return null;
    
    return ChatRoomModel.fromJson(
      json: doc.data()!,
      chatRoomId: doc.id,
    );
  }
}

final chatRoomsRepo = Provider((ref) => ChatRoomsRepository());