import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok_clone/screens/features/inbox/models/chat_room_model.dart';
import 'package:tiktok_clone/screens/features/inbox/repo/chat_rooms_repo.dart';

// 특정 채팅방 정보를 가져오는 Provider
final chatRoomDetailProvider = FutureProvider.family<ChatRoomModel?, String>((ref, chatRoomId) async {
  final repository = ref.read(chatRoomsRepo);
  return await repository.getChatRoom(chatRoomId);
});

// 채팅 상대방 정보를 추출하는 Provider
final chatPartnerInfoProvider = Provider.family<Map<String, String>, String>((ref, chatRoomId) {
  final chatRoomAsync = ref.watch(chatRoomDetailProvider(chatRoomId));
  final currentUser = ref.read(authRepo).user;
  
  return chatRoomAsync.when(
    data: (chatRoom) {
      if (chatRoom == null || currentUser == null) {
        return {'name': 'Unknown', 'id': ''};
      }
      
      // 현재 사용자가 personA인지 personB인지 확인하고 상대방 정보 반환
      if (chatRoom.personA == currentUser.uid) {
        return {
          'name': chatRoom.personBName,
          'id': chatRoom.personB,
        };
      } else {
        return {
          'name': chatRoom.personAName,
          'id': chatRoom.personA,
        };
      }
    },
    loading: () => {'name': 'Loading...', 'id': ''},
    error: (_, __) => {'name': 'Error', 'id': ''},
  );
});