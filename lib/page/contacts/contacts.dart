import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/page/communal/communal.dart';

import 'package:my_chat/page/home/component/slider_item.dart';
import 'package:my_chat/page/widget.dart/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:my_chat/utils/event_bus.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';

class ItemModel {
  String title;
  IconData icon;
  ItemModel(this.title, this.icon);
}

class Contacts extends StatefulWidget {
  Contacts({Key? key}) : super(key: key);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final CustomPopupMenuController _controller = CustomPopupMenuController();

  late List<ItemModel> menuItems;

  List itemList = [
    {
      "id": 1,
      "title": "新的朋友",
      "color": HexColor.fromHex('#5CACEE'),
      "icon": 0xe605
    },
    {
      "id": 2,
      "title": "群聊",
      "color": HexColor.fromHex('#66CDAA'),
      "icon": 0xe611
    },
    {
      "id": 3,
      "title": "黑名单",
      "color": HexColor.fromHex('#EE7942'),
      "icon": 0xe618
    },
  ];

  List<V2TimFriendInfo> friendList = []; //好友列表

  @override
  void initState() {
    super.initState();
    menuItems = [
      ItemModel(
        '发起群聊',
        IconData(0xe611, fontFamily: "icons"),
      ),
      ItemModel(
        '添加朋友',
        IconData(0xe8ca, fontFamily: "icons"),
      ),
      ItemModel(
        '扫一扫',
        IconData(0xe605, fontFamily: "icons"),
      ),
      ItemModel(
        '帮助与反馈',
        IconData(0xe600, fontFamily: "icons"),
      ),
    ];
    friendList = Provider.of<Chat>(context, listen: false).friendList;
  }

  _menuToPage(title) {
    switch (title) {
      case "发起群聊":
        Fluttertoast.showToast(msg: "该功能还在开发中...");
        break;
      case "添加朋友":
        Application.router.navigateTo(
          context,
          "/addFriendPage",
          transition: TransitionType.inFromRight,
        );
        break;
      case "扫一扫":
        Fluttertoast.showToast(msg: "该功能还在开发中...");
        break;
      case "帮助与反馈":
        Fluttertoast.showToast(msg: "该功能还在开发中...");
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "通讯录",
          style: TextStyle(fontSize: 35.sp),
        ),
        actions: <Widget>[
          CustomPopupMenu(
            child: Container(
              child: Icon(
                IconData(0xe635, fontFamily: "icons"),
                color: Colors.black87,
                size: 40.r,
              ),
              padding: EdgeInsets.symmetric(horizontal: 35.r),
            ),
            menuBuilder: () => popupMenu(),
            pressType: PressType.singleClick,
            verticalMargin: -10,
            controller: _controller,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  search(),
                  Container(
                    child: Column(
                      children: itemList.map((e) {
                        return item(e);
                      }).toList(),
                    ),
                  ),
                  Container(
                    height: 40.h,
                    color: HexColor.fromHex('#f5f5f5'),
                  ),
                  Container(
                    child: Column(
                      children: friendList.asMap().keys.map((index) {
                        return friendListItem(friendList[index], index);
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  //弹出菜单
  Widget popupMenu() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        color: const Color(0xFF4C4C4C),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: menuItems
                .map(
                  (item) => GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _menuToPage(item.title);
                      _controller.hideMenu();
                    },
                    child: Container(
                      height: 80.h,
                      padding: EdgeInsets.symmetric(horizontal: 40.r),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            item.icon,
                            size: 40.r,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 20.r, right: 20.r),
                              padding: EdgeInsets.symmetric(vertical: 20.r),
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
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
        switch (e["id"]) {
          case 1:
            Application.router.navigateTo(
              context,
              "/friendNewPage",
              transition: TransitionType.inFromRight,
            );
            break;
          case 2:
            Application.router.navigateTo(
              context,
              "/friendNewPage",
              transition: TransitionType.inFromRight,
            );
            break;
          case 3:
            Application.router.navigateTo(
              context,
              "/friendNewPage",
              transition: TransitionType.inFromRight,
            );
            break;
          default:
        }
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
          ],
        ),
      ),
    );
  }

  //好友列表
  Widget friendListItem(V2TimFriendInfo item, index) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          CustomTap(
            tapColor: HexColor.fromHex('#f5f5f5'),
            onTap: () {
              Provider.of<Chat>(context, listen: false)
                  .getFriendsInfo(item.userProfile!.userID, context);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin:
                      EdgeInsets.symmetric(vertical: 10.r, horizontal: 25.r),
                  height: 75.r,
                  width: 75.r,
                  child: Avatar(
                    isSelf: false,
                    size: 75.r,
                    faceUrl: item.userProfile!.faceUrl,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10.r),
                  child: Text(
                    "${item.userProfile!.nickName}",
                    style: TextStyle(fontSize: 30.sp),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 100.r),
            child: Divider(
              height: 1.r,
              color: HexColor.fromHex('#F8F8FB'),
            ),
          ),
          friendList.length - 1 == index
              ? Container(
                  padding: EdgeInsets.all(10.r),
                  child: Text(
                    "${friendList.length}位联系人",
                    style: TextStyle(
                      color: Colors.black26,
                      fontSize: 28.sp,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
