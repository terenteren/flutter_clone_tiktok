import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/inbox/models/message.dart';

// 각 채팅방의 마지막 메시지를 가져오는 Provider
final lastMessageProvider = StreamProvider.family<MessageModel?, String>((ref, chatRoomId) {
  final db = FirebaseFirestore.instance;
  
  return db
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('texts')
      .orderBy('createdAt', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return null;
        }
        
        final doc = snapshot.docs.first;
        return MessageModel.fromJson(
          doc.data(),
          docId: doc.id,
        );
      });
});