import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok_clone/screens/features/inbox/models/user_profile_model.dart';
import 'package:tiktok_clone/screens/features/inbox/repo/users_repo.dart';

class UsersViewModel extends AsyncNotifier<List<UserProfileModel>> {
  late final UsersRepository _repository;
  List<UserProfileModel> _users = [];
  
  @override
  FutureOr<List<UserProfileModel>> build() async {
    _repository = ref.read(usersRepo);
    return await _fetchUsers();
  }

  Future<List<UserProfileModel>> _fetchUsers() async {
    final currentUser = ref.read(authRepo).user;
    // 모든 유저를 가져오기
    final users = await _repository.fetchAllUsers();
    
    // 현재 사용자를 목록에서 제외
    final filteredUsers = users.where((user) => user.uid != currentUser?.uid).toList();
    
    _users = filteredUsers;
    return filteredUsers;
  }

  Future<void> fetchNextPage() async {
    // 페이지네이션 비활성화 - 모든 유저를 한번에 가져오므로 추가 로드 불필요
    return;
  }

  void refresh() async {
    state = const AsyncValue.loading();
    _users = [];
    state = AsyncValue.data(await _fetchUsers());
  }
}

final usersProvider = AsyncNotifierProvider<UsersViewModel, List<UserProfileModel>>(
  () => UsersViewModel(),
);