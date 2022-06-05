import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/common_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/src/provider.dart';
import 'package:text_span_field_null_safety/text_span_builder.dart';

class EmoTicon extends StatefulWidget {
  String converID;
  bool isGroup;
  TextSpanBuilder textSpanBuilder;
  EmoTicon({
    required this.textSpanBuilder,
    required this.converID,
    required this.isGroup,
    Key? key,
  }) : super(key: key);

  @override
  State<EmoTicon> createState() => _EmoTiconState();
}

class _EmoTiconState extends State<EmoTicon>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @protected
  bool get wantKeepAlive => true; //保持页面 tab
  TabController? _tabController; //tab 控制器

  int _currentTopTabIndex = 0; //表情包 tab

  List<dynamic> emoList = [];

  List<dynamic> latelyEmo = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabController =
        TabController(initialIndex: 0, length: 3, vsync: this); // 直接传this
    _tabController!.addListener(() {
      if (_tabController!.index == _tabController!.animation!.value) {
        // 当然只是给index赋值影响不大,最多重复赋值
        _currentTopTabIndex = _tabController!.index;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    emoList = context.watch<Common>().emojiList;
    latelyEmo = context.watch<Common>().latelyEmo;
    return Container(
      width: MediaQuery.of(context).size.width,
      color: HexColor.fromHex("#F7F7F6"),
      child: Container(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: const BoxDecoration(),
                indicatorWeight: 0.1,
                tabs: [
                  Container(
                    padding: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                      color: _currentTopTabIndex == 0 ? Colors.white : null,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      const IconData(0xe60b, fontFamily: "icons"),
                      size: 45.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                      color: _currentTopTabIndex == 1 ? Colors.white : null,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      const IconData(0xe612, fontFamily: "icons"),
                      size: 45.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                      color: _currentTopTabIndex == 2 ? Colors.white : null,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      const IconData(0xe6f8, fontFamily: "icons"),
                      size: 45.sp,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1.h, color: Colors.black12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  classicEmo(),
                  customEmo(),
                  selfEmo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //系统经典表情包
  Widget classicEmo() {
    return Stack(
      children: [
        Container(
          color: HexColor.fromHex('#EDEDED'),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                latelyEmo.isEmpty
                    ? Container()
                    : Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 40.r, top: 20.r),
                              child: Text(
                                "最近使用",
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            GridView.custom(
                              padding: EdgeInsets.symmetric(horizontal: 20.r),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8,
                                mainAxisSpacing: 0.0,
                                crossAxisSpacing: 5.0,
                              ),
                              childrenDelegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return TextButton(
                                    style: ButtonStyle(
                                      overlayColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.transparent), //splashColor
                                      padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry>(
                                          EdgeInsets.all(0)),
                                      backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) {
                                        //设置按下时的背景颜色
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return Colors.black12;
                                        }
                                        //默认不使用背景颜色
                                        return null;
                                      }),
                                    ),
                                    onPressed: () {
                                      widget.textSpanBuilder.appendTextToCursor(
                                          String.fromCharCode(
                                              emoList[index]["unicode"]));
                                      Provider.of<Common>(context,
                                              listen: false)
                                          .savelatelyEmo(emoList[index]);
                                    },
                                    child: Text(
                                      String.fromCharCode(
                                          emoList[index]["unicode"]),
                                      style: TextStyle(fontSize: 50.sp),
                                    ),
                                  );
                                },
                                childCount: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                Container(
                  padding: EdgeInsets.only(left: 40.r, top: 20.r),
                  child: Text(
                    "所有表情",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GridView.builder(
                  cacheExtent: 500,
                  padding: EdgeInsets.symmetric(horizontal: 20.r),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 0.0,
                    crossAxisSpacing: 5.0,
                  ),
                  itemCount: emoList.length,
                  itemBuilder: ((context, index) {
                    return CustomTap(
                      bgColor: HexColor.fromHex('#EDEDED'),
                      tapColor: HexColor.fromHex('#f5f5f5'),
                      radius: 20.r,
                      onTap: () {
                        widget.textSpanBuilder.appendTextToCursor(
                            String.fromCharCode(emoList[index]["unicode"]));
                        Provider.of<Common>(context, listen: false)
                            .savelatelyEmo(emoList[index]);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          String.fromCharCode(emoList[index]["unicode"]),
                          style: TextStyle(fontSize: 50.sp),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: () {
              widget.textSpanBuilder.customDelete();
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 25.r, right: 30.r),
              padding: EdgeInsets.symmetric(horizontal: 25.r, vertical: 15.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.backspace_outlined,
                size: 35.sp,
                color: Colors.black38,
              ),
            ),
          ),
        )
      ],
    );
  }

  //特色表情包
  Widget customEmo() {
    return Container(
      color: HexColor.fromHex('#EDEDED'),
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20.r, top: 20.r),
              child: Text(
                "个性化表情",
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, //横轴三个子widget
                    childAspectRatio: 1.0 //宽高比为1时，子widget
                    ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 20,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      String customEmoText = "-CUSTOM-EMO-$index";
                      Provider.of<Chat>(context, listen: false).createFaceMsg(
                          index,
                          customEmoText,
                          widget.converID,
                          widget.isGroup);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      child: Image.asset(
                        "assets/imgs/exemo/d$index.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  //自制表情包
  Widget selfEmo() {
    return Container(
      color: HexColor.fromHex('#EDEDED'),
      padding: EdgeInsets.only(top: 80.r),
      child: Column(
        children: [
          Container(
            child: Icon(
              Icons.add_a_photo,
              size: 100.sp,
              color: Colors.black12,
            ),
          ),
          Container(
            child: Text(
              "制作自己的表情包",
              style: TextStyle(color: Colors.black12, fontSize: 30.sp),
            ),
          )
        ],
      ),
    );
  }
}
