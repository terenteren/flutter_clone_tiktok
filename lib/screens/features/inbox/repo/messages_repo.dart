import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/inbox/models/message.dart';

class MessagesRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendMessage(MessageModel message, String chatRoomId) async {
    // 메시지 전송
    await _db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection("texts")
        .add(message.toJson());
    
    // 채팅방의 마지막 메시지 시간 업데이트 (상대방이 채팅방 목록에서 볼 수 있도록)
    await _db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .update({
          'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        });
  }

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    // 메시지를 실제로 삭제하지 않고, isDeleted를 true로 업데이트
    await _db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection("texts")
        .doc(messageId)
        .update({
      'isDeleted': true,
      'text': '[deleted message]',  // 원본 텍스트도 변경
    });
  }
}

final messagesRepo = Provider((ref) => MessagesRepo());
