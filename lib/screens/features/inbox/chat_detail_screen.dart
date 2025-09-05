import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/screens/features/authentication/repos/authentication_Repo.dart';
import 'package:tiktok_clone/screens/features/inbox/models/message.dart';
import 'package:tiktok_clone/screens/features/inbox/view_models/chat_room_detail_view_model.dart';
import 'package:tiktok_clone/screens/features/inbox/view_models/messages_view_model.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  static const String routeName = "chatDetail";
  static const String routeURL = ":chatId";

  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _isTextEmpty = _textController.text.isEmpty;
      });
    });
    // 채팅방 ID 설정
    ref.read(messagesProvider.notifier).setChatRoomId(widget.chatId);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onSendPress() {
    final text = _textController.text;
    if (text == "") return;
    ref.read(messagesProvider.notifier).sendMessage(text);
    _textController.text = "";
    _textController.clear();
  }

  void _onMessageLongPress(MessageModel message) async {
    // 자신의 메시지만 삭제 가능
    final currentUser = ref.read(authRepo).user;
    if (currentUser == null || message.userId != currentUser.uid) {
      return;
    }

    // 이미 삭제된 메시지는 다시 삭제할 수 없음
    if (message.isDeleted) {
      return;
    }

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메시지 삭제'),
        content: const Text('이 메시지를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && message.id != null) {
      await ref.read(messagesProvider.notifier).deleteMessage(message.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(messagesProvider).isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, child) {
            final partnerInfo = ref.watch(chatPartnerInfoProvider(widget.chatId));
            final partnerName = partnerInfo['name'] ?? 'Unknown';
            final partnerId = partnerInfo['id'] ?? '';
            
            return Row(
              children: [
                CircleAvatar(
                  radius: Sizes.size20,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: partnerId.isNotEmpty
                      ? NetworkImage(
                          "https://firebasestorage.googleapis.com/v0/b/kift-tiktok-clone-v1.firebasestorage.app/o/avatars%2F$partnerId?alt=media",
                        )
                      : null,
                  child: Text(
                    partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: Sizes.size16),
                  ),
                ),
                Gaps.h12,
                Text(
                  partnerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: Sizes.size16,
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: false,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            ref
                .watch(chatProvider(widget.chatId))
                .when(
                  data: (data) {
                    return ListView.separated(
                      reverse: true, // 최신 메시지가 아래에 오도록
                      padding: EdgeInsets.only(
                        top: Sizes.size20,
                        bottom:
                            MediaQuery.of(context).padding.bottom +
                            Sizes.size96,
                        left: Sizes.size14,
                        right: Sizes.size14,
                      ),
                      itemBuilder: (context, index) {
                        final message = data[index];
                        final isMine =
                            message.userId == ref.watch(authRepo).user!.uid;
                        return GestureDetector(
                          onLongPress: () => _onMessageLongPress(message),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: isMine
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(Sizes.size14),
                                decoration: BoxDecoration(
                                  color: message.isDeleted
                                      ? Colors.grey.shade400
                                      : (isMine
                                          ? Colors.blue
                                          : Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(Sizes.size20),
                                    topRight: Radius.circular(Sizes.size20),
                                    bottomLeft: Radius.circular(
                                      isMine ? Sizes.size20 : Sizes.size5,
                                    ),
                                    bottomRight: Radius.circular(
                                      isMine ? Sizes.size5 : Sizes.size20,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  message.text,
                                  style: TextStyle(
                                    color: message.isDeleted
                                        ? Colors.grey.shade600
                                        : (isDark ? Colors.black : Colors.white),
                                    fontSize: Sizes.size16,
                                    fontStyle: message.isDeleted
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ); // 각 아이템
                      },
                      separatorBuilder: (context, index) => Gaps.v10, // 간격
                      itemCount: data.length, // 아이템 개수
                    );
                  },
                  error: (error, stackTrace) =>
                      Center(child: Text(error.toString())),
                  loading: () => Center(child: CircularProgressIndicator()),
                ),
            Positioned(
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              child: Container(
                color: Colors.grey.shade50,
                padding: EdgeInsets.only(
                  left: Sizes.size16,
                  right: Sizes.size16,
                  top: Sizes.size12,
                  bottom: MediaQuery.of(context).padding.bottom + Sizes.size12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: Sizes.size44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(Sizes.size24),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                cursorColor: Theme.of(context).primaryColor,
                                textAlignVertical: TextAlignVertical.center,
                                style: TextStyle(
                                  fontSize: Sizes.size16,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Send a message...",
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade400,
                                    fontSize: Sizes.size14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                    left: Sizes.size16,
                                    right: Sizes.size8,
                                  ),
                                  isDense: true,
                                ),
                              ),
                            ),
                            // GestureDetector(
                            //   onTap: () {
                            //     // TODO: 이모티콘 선택
                            //   },
                            //   child: Padding(
                            //     padding: EdgeInsets.symmetric(
                            //       horizontal: Sizes.size12,
                            //     ),
                            //     child: FaIcon(
                            //       FontAwesomeIcons.faceSmile,
                            //       color: Colors.grey.shade600,
                            //       size: Sizes.size20,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Gaps.h10,
                    GestureDetector(
                      onTap: isLoading ? null : _onSendPress,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: Sizes.size44,
                        width: Sizes.size44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isTextEmpty
                              ? Colors.grey.shade300
                              : Theme.of(context).primaryColor,
                        ),
                        child: Center(
                          child: FaIcon(
                            isLoading
                                ? FontAwesomeIcons.hourglass
                                : FontAwesomeIcons.solidPaperPlane,
                            size: Sizes.size18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
