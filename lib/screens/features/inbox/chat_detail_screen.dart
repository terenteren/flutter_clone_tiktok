import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
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
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onSendTap() {
    if (_textController.text.isNotEmpty) {
      // TODO: 메시지 전송 로직
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          horizontalTitleGap: Sizes.size8,
          leading: CircleAvatar(
            radius: Sizes.size24,
            backgroundColor: Colors.grey.shade200,
            foregroundImage: NetworkImage(
              "https://avatars.githubusercontent.com/u/45036059?v=4",
            ),
            child: Text("테렌"),
          ),
          title: Text("테렌", style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text("Active 3h ago"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.flag,
                color: Colors.black,
                size: Sizes.size20,
              ),
              Gaps.h32,
              FaIcon(
                FontAwesomeIcons.ellipsis,
                color: Colors.black,
                size: Sizes.size20,
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            ListView.separated(
            padding: EdgeInsets.only(
              top: Sizes.size20,
              bottom: Sizes.size96 + Sizes.size20,
              left: Sizes.size14,
              right: Sizes.size14,
            ),
            itemBuilder: (context, index) {
              final isMine = index % 2 == 0;
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isMine
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(Sizes.size14),
                    decoration: BoxDecoration(
                      color: isMine
                          ? Colors.blue
                          : Theme.of(context).primaryColor,
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
                      "this is a message!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Sizes.size16,
                      ),
                    ),
                  ),
                ],
              ); // 각 아이템
            },
            separatorBuilder: (context, index) => Gaps.v10, // 간격
            itemCount: 10, // 아이템 개수
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
                              ),
                              decoration: InputDecoration(
                                hintText: "Send a message...",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
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
                          GestureDetector(
                            onTap: () {
                              // TODO: 이모티콘 선택
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: Sizes.size12),
                              child: FaIcon(
                                FontAwesomeIcons.faceSmile,
                                color: Colors.grey.shade600,
                                size: Sizes.size20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gaps.h10,
                  GestureDetector(
                    onTap: _onSendTap,
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
                          FontAwesomeIcons.solidPaperPlane,
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
