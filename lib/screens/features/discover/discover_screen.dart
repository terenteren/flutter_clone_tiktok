import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiktok_clone/constants/breakpoint.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';

final tabs = ["Top", "Users", "Videos", "Sounds", "LIVE", "Shopping", "Brands"];

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _textEditingController = TextEditingController(
    text: "", // 초기 텍스트
  );

  void _onSearchChanged(String value) {}

  void _onSearchSubmitted(String value) {}

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _onTapBody() {
    FocusScope.of(context).unfocus(); // 키보드 숨기기
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: tabs.length,
      child: GestureDetector(
        onTap: _onTapBody,
        child: Scaffold(
          resizeToAvoidBottomInset: false, // 키보드로 인해 화면이 리사이즈 되는 것을 방지
          appBar: AppBar(
            elevation: 1,
            title: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: Breakpoints.sm),
                child: CupertinoSearchTextField(
                  controller: _textEditingController,
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchSubmitted,
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: Breakpoints.sm),
                  child: TabBar(
                    onTap: (value) => FocusScope.of(context).unfocus(),
                    splashFactory: NoSplash.splashFactory,
                    padding: EdgeInsets.symmetric(horizontal: Sizes.size6),
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade500,
                    tabs: [for (var tab in tabs) Tab(text: tab)],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              GridView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag, // 드래그 시 키보드 숨기기
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: width > Breakpoints.md ? 4 : 2, // 한 줄에 n개
                  crossAxisSpacing: Sizes.size10, // 수평 간격
                  mainAxisSpacing: Sizes.size10, // 수직 간격
                  childAspectRatio: 9 / 20, // 너비 / 높이 비율
                ),
                itemCount: 20,
                padding: EdgeInsets.symmetric(
                  horizontal: Sizes.size6,
                  vertical: Sizes.size6,
                ),
                itemBuilder: (context, index) => LayoutBuilder(
                  builder: (context, constraints) => Column(
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Sizes.size4),
                        ),
                        child: AspectRatio(
                          aspectRatio: 9 / 15,
                          child: FadeInImage.assetNetwork(
                            fit: BoxFit.cover,
                            placeholder: "assets/images/walk_on_forest.jpeg",
                            image:
                                "https://plus.unsplash.com/premium_photo-1755856680228-60755545c4ec?q=80&w=2340&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                          ),
                        ),
                      ),
                      Gaps.v10,

                      Text(
                        "${constraints.maxWidth} This is a very long caption for my video that I'm uploading just now #video #myvideo #fyp #flutter #dartlang",
                        style: TextStyle(
                          fontSize: Sizes.size16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gaps.v8,
                      if (constraints.maxWidth < 200 ||
                          constraints.maxWidth > 250)
                        DefaultTextStyle(
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(
                                  "https://avatars.githubusercontent.com/u/33644179?v=4",
                                ),
                              ),
                              Gaps.h4,
                              Expanded(
                                child: Text(
                                  "My avatar is going to be very long",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Gaps.h4,
                              FaIcon(
                                FontAwesomeIcons.heart,
                                size: Sizes.size16,
                                color: Colors.grey.shade600,
                              ),
                              Gaps.h4,
                              Text("2.5M"),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              for (var tab in tabs.skip(1))
                Center(child: Text(tab, style: TextStyle(fontSize: 49))),
            ],
          ),
        ),
      ),
    );
  }
}
