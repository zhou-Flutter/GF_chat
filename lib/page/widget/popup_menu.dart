import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/model/menu_item.dart';

class PopupMenu extends StatefulWidget {
  PopupMenu({Key? key}) : super(key: key);

  @override
  State<PopupMenu> createState() => _PopupMenuState();
}

class _PopupMenuState extends State<PopupMenu> {
  final CustomPopupMenuController _controller = CustomPopupMenuController();

  late List<MenuItemModel> menuItems;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    menuItems = [
      MenuItemModel(
        1,
        '发起群聊',
        IconData(0xe611, fontFamily: "icons"),
      ),
      MenuItemModel(
        2,
        '添加朋友',
        IconData(0xe8ca, fontFamily: "icons"),
      ),
      MenuItemModel(
        3,
        '扫一扫',
        IconData(0xe605, fontFamily: "icons"),
      ),
      MenuItemModel(
        4,
        '帮助与反馈',
        IconData(0xe600, fontFamily: "icons"),
      ),
    ];
  }

  _menuToPage(id) {
    switch (id) {
      case 1:
        Application.router.navigateTo(
          context,
          "/createGroup",
          transition: TransitionType.inFromRight,
        );
        break;
      case 2:
        Application.router.navigateTo(
          context,
          "/addFriendPage",
          transition: TransitionType.inFromRight,
        );
        break;
      case 3:
        Fluttertoast.showToast(msg: "该功能还在开发中...");
        break;
      case 4:
        Fluttertoast.showToast(msg: "该功能还在开发中...");
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      child: Container(
        child: Icon(
          IconData(0xe635, fontFamily: "icons"),
          color: Colors.black87,
          size: 40.r,
        ),
        padding: EdgeInsets.symmetric(horizontal: 35.r),
      ),
      menuBuilder: () => popoMenu(),
      pressType: PressType.singleClick,
      verticalMargin: -10,
      controller: _controller,
    );
  }

  Widget popoMenu() {
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
                      _menuToPage(item.id);
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
}
