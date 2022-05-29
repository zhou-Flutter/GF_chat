import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/constant.dart';
import 'package:provider/provider.dart';

class AddFriendPage extends StatefulWidget {
  AddFriendPage({Key? key}) : super(key: key);

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage>
    with WidgetsBindingObserver {
  //输入框文本控制器
  TextEditingController textEditingController = TextEditingController();

  //控制焦点
  final FocusNode _focusNode = FocusNode();
  //软键盘是否显示
  bool isShow = false;
  //输入值
  var inputValue = "";

  List itemList = [
    {
      "id": 1,
      "title": "扫一扫",
      "subTit": "扫描二维码名片",
      "color": Colors.blue,
      "icon": 0xe605
    },
    {
      "id": 2,
      "title": "面对面建群",
      "subTit": "与身边朋友加入群聊",
      "color": Colors.green,
      "icon": 0xe611
    },
    {
      "id": 3,
      "title": "手机联系人",
      "subTit": "添加或邀请通讯录中的好友",
      "color": Colors.yellow,
      "icon": 0xe618
    },
  ];

  @override
  void initState() {
    super.initState();

    //初始化 键盘监听
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          if (MediaQuery.of(context).viewInsets.bottom == 0) {
            //关闭键盘
            isShow = false;
          } else {
            //显示键盘
            isShow = true;
          }
        });
      }
    });
  }

  //搜索是否有好友 如果有则跳转到加好友页面
  searchFriend() async {
    Provider.of<Friend>(context, listen: false)
        .getFriendsInfo(inputValue, context);
    textEditingController.clear();
    inputValue = "";
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            Constant.assetsImg + 'back_blc.png',
            width: 40.w,
          ),
          onPressed: () {
            Application.router.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          "添加好友",
          style: TextStyle(fontSize: 30.sp),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(30.r),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      height: 60.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: HexColor.fromHex("#F3F3F3"),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: TextField(
                        controller: textEditingController,
                        focusNode: _focusNode,
                        autofocus: false,
                        decoration: const InputDecoration(
                          hintText: "肝聊号/手机号",
                          prefixIcon: Icon(
                            IconData(0xeafe, fontFamily: "icons"),
                            color: Colors.black26,
                          ),
                          prefixIconConstraints: BoxConstraints(minWidth: 10),
                          filled: false,
                          isCollapsed: true,
                          border: InputBorder.none,
                        ),
                        onChanged: (e) {
                          print(e);
                          inputValue = e;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  isShow == true
                      ? InkWell(
                          onTap: () {
                            textEditingController.clear();
                            inputValue = "";
                            FocusScope.of(context).unfocus();
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 20.r),
                            child: Text(
                              "取消",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 30.sp,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            isShow == true
                ? searchText()
                : Container(
                    child: Column(
                      children: itemList.map((e) {
                        return item(e);
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget searchText() {
    return inputValue.length > 0
        ? InkWell(
            onTap: () {
              searchFriend();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.r),
              child: Row(
                children: [
                  Text(
                    "搜索",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 30.sp,
                    ),
                  ),
                  SizedBox(
                    width: 15.r,
                  ),
                  Text(
                    inputValue,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30.sp,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  // 扫一扫等功能
  Widget item(e) {
    return Container(
      child: Container(
        padding: EdgeInsets.all(25.r),
        child: Row(
          children: [
            Container(
              height: 75.r,
              width: 75.r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                color: e["color"],
              ),
              child: Icon(
                IconData(e["icon"], fontFamily: "icons"),
                size: 35.sp,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 25.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e["title"],
                      style: TextStyle(
                          fontSize: 30.sp, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      e["subTit"],
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Colors.black45,
                      ),
                    )
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
