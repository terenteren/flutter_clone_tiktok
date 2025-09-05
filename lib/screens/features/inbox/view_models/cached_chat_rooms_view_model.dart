import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok_clone/screens/features/inbox/models/chat_room_model.dart';
import 'package:tiktok_clone/screens/features/inbox/repo/chat_rooms_repo.dart';

// 채팅방 목록을 캐싱하고 관리하는 StateNotifier
class CachedChatRoomsViewModel extends StateNotifier<AsyncValue<List<ChatRoomModel>>> {
  final Ref _ref;
  StreamSubscription? _subscription;
  
  CachedChatRoomsViewModel(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }
  
  void _initialize() {
    final user = _ref.read(authRepo).user;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }
    
    final repository = _ref.read(chatRoomsRepo);
    
    // Stream을 구독하여 상태 업데이트
    _subscription?.cancel();
    _subscription = repository.getChatRooms(user.uid).listen(
      (chatRooms) {
        state = AsyncValue.data(chatRooms);
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  
  // 수동 새로고침
  void refresh() {
    state = const AsyncValue.loading();
    _initialize();
  }
}

// keepAlive: true로 설정하여 provider가 dispose되지 않도록 함
final cachedChatRoomsProvider = StateNotifierProvider<CachedChatRoomsViewModel, AsyncValue<List<ChatRoomModel>>>((ref) {
  // keepAlive를 통해 화면 전환 시에도 데이터 유지
  ref.keepAlive();
  return CachedChatRoomsViewModel(ref);
});