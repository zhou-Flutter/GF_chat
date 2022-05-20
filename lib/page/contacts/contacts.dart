import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/model/menu_item.dart';
import 'package:my_chat/page/communal/communal.dart';
import 'package:my_chat/page/contacts/component/friend_list.dart';

import 'package:my_chat/page/home/component/slider_item.dart';

import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/page/widget/popup_menu.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:my_chat/utils/event_bus.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';

class Contacts extends StatefulWidget {
  Contacts({Key? key}) : super(key: key);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List itemList = [
    {
      "id": 1,
      "title": "新的朋友",
      "color": HexColor.fromHex('#5CACEE'),
      "icon": 0xe605,
      "unread": 0
    },
    {
      "id": 2,
      "title": "群聊",
      "color": HexColor.fromHex('#66CDAA'),
      "icon": 0xe611,
      "unread": 0
    },
    {
      "id": 3,
      "title": "黑名单",
      "color": HexColor.fromHex('#EE7942'),
      "icon": 0xe618,
      "unread": 0
    },
  ];

  List<V2TimFriendInfo> friendList = []; //好友列表

  @override
  void initState() {
    super.initState();
    friendList = Provider.of<Chat>(context, listen: false).friendList;
  }

  //跳转页面
  toPage(e) {
    switch (e["id"]) {
      case 1:
        Application.router.navigateTo(
          context,
          "/friendNewPage",
          transition: TransitionType.inFromRight,
        );
        break;
      case 2:
        print("开发中");
        break;
      case 3:
        Application.router.navigateTo(
          context,
          "/blackList",
          transition: TransitionType.inFromRight,
        );
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    itemList[0]["unread"] = context.watch<Chat>().friendApplicationUnreadCount;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "通讯录",
          style: TextStyle(fontSize: 35.sp),
        ),
        actions: <Widget>[
          PopupMenu(),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                search(),
                Column(
                  children: itemList.map((e) {
                    return item(e);
                  }).toList(),
                ),
                FriendList(friendList: friendList),
                numFriend(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //显示有多少好友
  Widget numFriend() {
    return friendList.isEmpty
        ? Column(
            children: [
              Container(
                height: 40.h,
                width: MediaQuery.of(context).size.width,
                color: HexColor.fromHex('#f5f5f5'),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 50.r),
                child: Text(
                  "暂无联系人",
                  style: TextStyle(
                    color: Colors.black26,
                    fontSize: 30.sp,
                  ),
                ),
              )
            ],
          )
        : Container(
            padding: EdgeInsets.symmetric(vertical: 50.r),
            child: Text(
              "${friendList.length}位联系人",
              style: TextStyle(
                color: Colors.black26,
                fontSize: 30.sp,
              ),
            ),
          );
  }

  Widget search() {
    return Container(
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 25.r, vertical: 25.r),
        padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 15.r),
        decoration: BoxDecoration(
          color: HexColor.fromHex('#F5F7FB'),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              IconData(0xeafe, fontFamily: "icons"),
              color: Colors.black26,
            ),
            Text(
              "搜索",
              style: TextStyle(
                color: Colors.black26,
                fontSize: 28.sp,
              ),
            )
          ],
        ),
      ),
    );
  }

  // 新朋友 群聊 黑名单
  Widget item(e) {
    return CustomTap(
      tapColor: HexColor.fromHex('#f5f5f5'),
      onTap: () {
        toPage(e);
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 75.r,
              width: 75.r,
              margin: EdgeInsets.symmetric(vertical: 10.r, horizontal: 25.r),
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
            Container(
              padding: EdgeInsets.only(left: 10.r),
              child: Text(
                e["title"],
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w400),
              ),
            ),
            const Spacer(),
            e["unread"] == 0
                ? Container()
                : Container(
                    width: 30.r,
                    height: 30.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: Text(
                      "${e["unread"]}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
            SizedBox(width: 20.r),
          ],
        ),
      ),
    );
  }
}
