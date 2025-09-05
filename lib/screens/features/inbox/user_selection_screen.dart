import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok_clone/screens/features/inbox/chat_detail_screen.dart';
import 'package:tiktok_clone/screens/features/inbox/models/user_profile_model.dart';
import 'package:tiktok_clone/screens/features/inbox/view_models/chat_rooms_view_model.dart';
import 'package:tiktok_clone/screens/features/inbox/view_models/users_view_model.dart';

class UserSelectionScreen extends ConsumerStatefulWidget {
  static const String routeName = "userSelection";
  static const String routeURL = "/userSelection";
  
  const UserSelectionScreen({super.key});

  @override
  ConsumerState<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends ConsumerState<UserSelectionScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCreatingRoom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(usersProvider.notifier).fetchNextPage();
    }
  }

  void _onUserSelect(UserProfileModel user) async {
    // 이미 생성 중이면 중복 실행 방지
    if (_isCreatingRoom) return;
    
    setState(() {
      _isCreatingRoom = true;
    });
    
    try {
      // 현재 사용자 정보 가져오기
      final currentUser = ref.read(authRepo).user;
      if (currentUser == null) return;
      
      // 채팅방 ID 생성 (두 사용자 ID를 정렬해서 조합)
      final List<String> userIds = [currentUser.uid, user.uid]..sort();
      final chatRoomId = userIds.join('_');
      
      // 채팅방 생성
      await ref.read(chatRoomsProvider.notifier).createChatRoom(user.uid, user.name);
      
      // 채팅방으로 직접 이동
      if (mounted) {
        // 먼저 선택 화면을 닫고
        Navigator.of(context).pop();
        
        // 잠시 대기 후 채팅방으로 이동 (목록 업데이트 시간 확보)
        await Future.delayed(const Duration(milliseconds: 100));
        
        // mounted 체크 후 네비게이션
        if (mounted) {
          context.pushNamed(
            ChatDetailScreen.routeName,
            params: {"chatId": chatRoomId},
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅방 생성 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingRoom = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대화 상대 선택'),
        elevation: 1,
      ),
      body: ref.watch(usersProvider).when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(
              child: Text(
                '사용자가 없습니다.',
                style: TextStyle(fontSize: Sizes.size16),
              ),
            );
          }
          
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: Sizes.size10),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Sizes.size16,
                  vertical: Sizes.size8,
                ),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: user.hasAvatar
                      ? NetworkImage(
                          "https://firebasestorage.googleapis.com/v0/b/kift-tiktok-clone-v1.firebasestorage.app/o/avatars%2F${user.uid}?alt=media",
                        )
                      : null,
                  child: !user.hasAvatar
                      ? Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: Sizes.size20),
                        )
                      : null,
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: Sizes.size16,
                  ),
                ),
                subtitle: Text(
                  user.bio.isNotEmpty ? user.bio : '안녕하세요!',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: Sizes.size14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: GestureDetector(
                  onTap: () => _onUserSelect(user),
                  child: Container(
                    width: Sizes.size44,
                    height: Sizes.size44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.check,
                        color: Colors.white,
                        size: Sizes.size20,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.triangleExclamation,
                size: Sizes.size40,
                color: Colors.red,
              ),
              Gaps.v20,
              Text(
                '오류가 발생했습니다.\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: Sizes.size16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}