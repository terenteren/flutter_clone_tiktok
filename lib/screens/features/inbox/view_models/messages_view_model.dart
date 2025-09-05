import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_Repo.dart';
import 'package:tiktok_clone/screens/features/inbox/models/message.dart';
import 'package:tiktok_clone/screens/features/inbox/repo/messages_repo.dart';

class MessagesViewModel extends AsyncNotifier {
  late final MessagesRepo _repo;
  String? _chatRoomId;

  @override
  FutureOr<void> build() {
    _repo = ref.read(messagesRepo);
  }

  void setChatRoomId(String chatRoomId) {
    _chatRoomId = chatRoomId;
  }

  Future<void> sendMessage(String text) async {
    if (_chatRoomId == null) return;
    
    final user = ref.read(authRepo).user;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final message = MessageModel(
        text: text,
        userId: user!.uid,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _repo.sendMessage(message, _chatRoomId!);
    });
  }

  Future<void> deleteMessage(String messageId) async {
    if (_chatRoomId == null) return;
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteMessage(_chatRoomId!, messageId);
    });
  }
}

final messagesProvider = AsyncNotifierProvider<MessagesViewModel, void>(
  () => MessagesViewModel(),
);

final chatProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatRoomId) {
  final db = FirebaseFirestore.instance;
  return db
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection("texts")
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (event) =>
            event.docs.map((doc) => MessageModel.fromJson(
              doc.data(), 
              docId: doc.id,  // Document ID 전달
            )).toList(),
      );
});
