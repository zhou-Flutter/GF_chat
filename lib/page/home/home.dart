import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_floating/floating/assist/floating_slide_type.dart';
import 'package:flutter_floating/floating/floating.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';
import 'package:flutter_floating/floating_increment.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/page/home/component/c2c_converstation_item.dart';
import 'package:my_chat/page/home/component/group_converstation_item.dart';
import 'package:my_chat/page/home/component/slider_item.dart';

import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/page/widget/popup_menu.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/init_im_sdk_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/relative_date_format.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

class ItemModel {
  String title;
  IconData icon;

  ItemModel(this.title, this.icon);
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<V2TimConversation> currentMessageList = [];

  List<V2TimUserFullInfo> selfInfo = [];

  @override
  void initState() {
    super.initState();

    Provider.of<Chat>(context, listen: false).getConversationList();
    selfInfo = Provider.of<Chat>(context, listen: false).selfInfo;
  }

  _onRefresh() {
    //下拉刷新
    Provider.of<Chat>(context, listen: false).getConversationList();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    currentMessageList = context.watch<Chat>().currentMessageList;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "聊天",
          style: TextStyle(fontSize: 35.sp),
        ),
        actions: <Widget>[
          PopupMenu(),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            search(),
            currentMessageList.isEmpty
                ? noCurrent()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: currentMessageList.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (currentMessageList[index].type == 1) {
                        return C2cConverItem(
                            key: UniqueKey(),
                            conversation: currentMessageList[index]);
                      } else {
                        return GroupConverItem(
                            key: UniqueKey(),
                            conversation: currentMessageList[index]);
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }

  //暂无会话
  Widget noCurrent() {
    return Container(
      padding: EdgeInsets.only(top: 300.r),
      child: Column(
        children: [
          Icon(
            IconData(0xe63c, fontFamily: "icons"),
            color: Colors.black12,
            size: 180.sp,
          ),
          Container(
            child: Text(
              "暂无会话",
              style: TextStyle(
                color: Colors.black26,
                fontSize: 30.sp,
              ),
            ),
          )
        ],
      ),
    );
  }

  //搜索
  Widget search() {
    return InkWell(
      onTap: () {
        Application.router.navigateTo(
          context,
          "/search",
          transition: TransitionType.inFromRight,
        );
      },
      child: Container(
        color: Colors.white,
        child: Container(
          margin: EdgeInsets.only(right: 25.r, left: 25.r, bottom: 25.r),
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
      ),
    );
  }
}
