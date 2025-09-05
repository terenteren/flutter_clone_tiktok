import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok_clone/screens/features/inbox/models/chat_room_model.dart';
import 'package:tiktok_clone/screens/features/inbox/repo/chat_rooms_repo.dart';

class ChatRoomsViewModel extends AsyncNotifier<void> {
  late final ChatRoomsRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.read(chatRoomsRepo);
  }

  Future<void> createChatRoom(String otherUserId, String otherUserName) async {
    final user = ref.read(authRepo).user;
    if (user == null) return;

    state = const AsyncValue.loading();
    
    try {
      // 현재 사용자의 이름은 displayName 또는 email에서 가져오기
      final currentUserName = user.displayName ?? user.email?.split('@')[0] ?? 'User';

      await _repository.createChatRoom(
        currentUserId: user.uid,
        currentUserName: currentUserName,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
      );
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final chatRoomsProvider = AsyncNotifierProvider<ChatRoomsViewModel, void>(
  () => ChatRoomsViewModel(),
);

// StreamProvider 대신 StreamProvider.autoDispose를 사용하지 않음으로써
// 화면 전환 시에도 데이터를 유지
final chatRoomsListProvider = StreamProvider<List<ChatRoomModel>>((ref) {
  final user = ref.read(authRepo).user;
  if (user == null) {
    return Stream.value([]);
  }
  
  final repository = ref.read(chatRoomsRepo);
  return repository.getChatRooms(user.uid);
});