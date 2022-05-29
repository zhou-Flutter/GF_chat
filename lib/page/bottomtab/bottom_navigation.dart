import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/assist/floating_slide_type.dart';
import 'package:flutter_floating/floating/floating.dart';
import 'package:flutter_floating/floating/listener/floating_listener.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';
import 'package:flutter_floating/floating_increment.dart';
import 'package:flutter_floating/main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/page/communal/communal.dart';
import 'package:my_chat/page/contacts/contacts.dart';
import 'package:my_chat/page/home/home.dart';
import 'package:my_chat/page/personal/personal.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/common_provider.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/provider/init_provider.dart';
import 'package:my_chat/provider/login_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:provider/provider.dart';

class BottomNav extends StatefulWidget {
  @override
  BottomNavState createState() => new BottomNavState();
}

class BottomNavState extends State<BottomNav>
    with SingleTickerProviderStateMixin {
  PageController? _controller;

  List<Widget> pages = [
    Home(),
    Contacts(),
    // Communal(),
    Personal(),
  ];
  int _currentIndex = 0;
  List<BottomNavigationBarItem> _bottomNavBarList = [];

  List butIcon = [
    {"id": 1, "icon": 0xe614, "name": "消息", "unRead": 0},
    {"id": 2, "icon": 0xe6c2, "name": "朋友", "unRead": 0},
    // {"id": 3, "icon": 0xe65b, "name": "社区", "unRead": 0},
    {"id": 3, "icon": 0xe7ea, "name": "我", "unRead": 0},
  ];

  @override
  void initState() {
    _controller = PageController(initialPage: 0);

    var userId = Provider.of<Login>(context, listen: false).selfId;
    Provider.of<Chat>(context, listen: false).getUnreadCount();
    Provider.of<Friend>(context, listen: false)
        .getFriendApplicationList(); //获取好友申请列表
    Provider.of<Friend>(context, listen: false).getFriendList(); //获取好友列表
    Provider.of<Friend>(context, listen: false).getSelfInfo(userId);
    Provider.of<Common>(context, listen: false).getSoundPathName();

    // var floatingOne = floatingManager
    //     .createFloating(
    //         "1",
    //         Floating(
    //           MyChatApp.navigatorKey,
    //           floatBtn(),
    //           // slideType: FloatingSlideType.onLeftAndTop,
    //           // left: 0,
    //           // top: 150,
    //           // slideBottomHeight: 0,
    //         ))
    //     .open();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = context.watch<Chat>().unreadCount;
    int friendApplicationUnreadCount =
        context.watch<Friend>().friendApplicationUnreadCount;
    butIcon[0]["unRead"] = unreadCount;
    butIcon[1]["unRead"] = friendApplicationUnreadCount;
    _bottomNavBarList = [
      _bottomNavBarItem(butIcon[0]),
      _bottomNavBarItem(butIcon[1]),
      _bottomNavBarItem(butIcon[2]),
      // _bottomNavBarItem(butIcon[3])
    ];
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          _currentIndex = index;
          setState(() {});
        },
        elevation: 1,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        iconSize: 35,
        fixedColor: HexColor.fromHex('#9266F3'),
        unselectedItemColor: Colors.black26,
        selectedFontSize: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        items: _bottomNavBarList,
      ),
    );
  }

  BottomNavigationBarItem _bottomNavBarItem(item) {
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            child: Icon(
              IconData(item["icon"], fontFamily: "icons"),
            ),
          ),
          Positioned(
            top: -10.r,
            right: -15.r,
            child: item["unRead"] == 0
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
                      "${item["unRead"]}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
          )
        ],
      ),
      activeIcon: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            child: Icon(
              IconData(item["icon"], fontFamily: "icons"),
            ),
          ),
          Positioned(
            top: -10.r,
            right: -15.r,
            child: item["unRead"] == 0
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
                      "${item["unRead"]}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
          )
        ],
      ),
      label: item["name"],
      tooltip: '',
    );
  }
}
