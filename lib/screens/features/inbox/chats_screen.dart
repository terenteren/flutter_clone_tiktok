import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok_clone/screens/features/inbox/chat_detail_screen.dart';
import 'package:tiktok_clone/screens/features/inbox/user_selection_screen.dart';
import 'package:tiktok_clone/screens/features/inbox/view_models/chat_rooms_view_model.dart';
import 'package:tiktok_clone/screens/features/inbox/view_models/last_message_view_model.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  static const String routeName = "chats";
  static const String routeURL = "/chats";
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  void _addItem() {
    // 유저 선택 화면으로 이동
    context.pushNamed(UserSelectionScreen.routeName);
  }

  void _onChatTap(String chatRoomId) {
    context.pushNamed(
      ChatDetailScreen.routeName,
      params: {"chatId": chatRoomId},
    );
  }

  String _getChatPartnerName(chatRoom, String currentUserId) {
    if (chatRoom.personA == currentUserId) {
      return chatRoom.personBName;
    } else {
      return chatRoom.personAName;
    }
  }

  String _getChatPartnerId(chatRoom, String currentUserId) {
    if (chatRoom.personA == currentUserId) {
      return chatRoom.personB;
    } else {
      return chatRoom.personA;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("Direct Messages"),
        actions: [
          IconButton(onPressed: _addItem, icon: FaIcon(FontAwesomeIcons.plus)),
        ],
      ),
      body: ref.watch(chatRoomsListProvider).when(
        data: (chatRooms) {
          final currentUser = ref.read(authRepo).user;
          if (currentUser == null) {
            return const Center(
              child: Text('로그인이 필요합니다.'),
            );
          }

          if (chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '채팅방이 없습니다.',
                    style: TextStyle(
                      fontSize: Sizes.size20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gaps.v20,
                  GestureDetector(
                    onTap: _addItem,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size24,
                        vertical: Sizes.size12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(Sizes.size20),
                      ),
                      child: const Text(
                        '대화 시작하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: Sizes.size10),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final partnerName = _getChatPartnerName(chatRoom, currentUser.uid);
              final partnerId = _getChatPartnerId(chatRoom, currentUser.uid);
              
              return ListTile(
                onTap: () => _onChatTap(chatRoom.id),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  foregroundImage: NetworkImage(
                    "https://firebasestorage.googleapis.com/v0/b/kift-tiktok-clone-v1.firebasestorage.app/o/avatars%2F$partnerId?alt=media",
                  ),
                  child: Text(
                    partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'U',
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      partnerName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final lastMessageAsync = ref.watch(lastMessageProvider(chatRoom.id));
                        
                        return lastMessageAsync.when(
                          data: (lastMessage) {
                            final messageTime = lastMessage != null
                                ? DateTime.fromMillisecondsSinceEpoch(lastMessage.createdAt)
                                : chatRoom.createdAt;
                            
                            // 오늘인지 확인
                            final now = DateTime.now();
                            final isToday = messageTime.year == now.year &&
                                messageTime.month == now.month &&
                                messageTime.day == now.day;
                            
                            String timeText;
                            if (isToday) {
                              timeText = '${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}';
                            } else {
                              timeText = '${messageTime.month}/${messageTime.day}';
                            }
                            
                            return Text(
                              timeText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            );
                          },
                          loading: () => Text(
                            '${chatRoom.createdAt.hour}:${chatRoom.createdAt.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          error: (_, __) => Text(
                            '${chatRoom.createdAt.hour}:${chatRoom.createdAt.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                subtitle: Consumer(
                  builder: (context, ref, child) {
                    final lastMessageAsync = ref.watch(lastMessageProvider(chatRoom.id));
                    
                    return lastMessageAsync.when(
                      data: (lastMessage) {
                        if (lastMessage == null) {
                          return const Text(
                            "메시지를 시작해보세요!",
                            style: TextStyle(color: Colors.grey),
                          );
                        }
                        
                        return Text(
                          lastMessage.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: lastMessage.isDeleted 
                                ? Colors.grey.shade500 
                                : Colors.grey.shade600,
                            fontStyle: lastMessage.isDeleted 
                                ? FontStyle.italic 
                                : FontStyle.normal,
                          ),
                        );
                      },
                      loading: () => const Text(
                        "...",
                        style: TextStyle(color: Colors.grey),
                      ),
                      error: (_, __) => const Text(
                        "메시지를 시작해보세요!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('오류가 발생했습니다: $error'),
        ),
      ),
    );
  }
}
