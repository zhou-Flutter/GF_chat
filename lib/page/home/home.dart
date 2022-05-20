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
        physics: const NeverScrollableScrollPhysics(),
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
                      return chatView(currentMessageList[index]);
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
    return Container(
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.only(right: 25.r, left: 25.r, bottom: 25.r),
        padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 15.r),
        decoration: BoxDecoration(
          color: HexColor.fromHex('#F5F7FB'),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: InkWell(
          onTap: () {
            print("跳转到搜索页面");
          },
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

  Widget chatView(V2TimConversation item) {
    var time = item.lastMessage!.timestamp;
    var recvOpt = item.recvOpt;
    var createTime = RelativeDateFormat.timeToBefore(time!);

    return SliderItem(
      isPinned: item.isPinned!,
      key: UniqueKey(),
      onTap: () {
        onTap(item);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25.r),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(right: 20.r),
              child: Avatar(
                size: 95.r,
                isSelf: false,
                faceUrl: item.faceUrl,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      "${item.showName}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 35.sp,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  msgStatus(item.lastMessage!)
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${createTime}",
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.black26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  item.unreadCount == 0
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
                            "${item.unreadCount}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                            ),
                          ),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
      toppingChild: item.isPinned == true
          ? Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {
                  Provider.of<Chat>(context, listen: false)
                      .pinConversation(item.conversationID, false);
                },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 10.r),
                  child: Text(
                    "取消置顶",
                    style: TextStyle(
                      fontSize: 30.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          : Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  Provider.of<Chat>(context, listen: false)
                      .pinConversation(item.conversationID, true);
                },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.blue,
                  child: Text(
                    "置顶",
                    style: TextStyle(
                      fontSize: 30.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              )),
      deleteChild: Expanded(
        flex: 2,
        child: InkWell(
          onTap: () {
            Provider.of<Chat>(context, listen: false)
                .deleteConversation(item.conversationID);
          },
          child: Container(
            alignment: Alignment.center,
            color: Colors.red,
            child: Text(
              "删除",
              style: TextStyle(
                fontSize: 30.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  //消息状态
  Widget msgStatus(V2TimMessage v2timMsg) {
    var lastmsg = "";
    switch (v2timMsg.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        lastmsg = v2timMsg.textElem!.text!;
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        lastmsg = "[自定义消息]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        lastmsg = "[图片]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        lastmsg = "[语音]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        lastmsg = "[视频]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        lastmsg = "[文件]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        lastmsg = "[表情包]";
        break;
      default:
    }
    switch (v2timMsg.status) {
      case 0:
        return Row(
          children: [
            Container(
              child: Text(
                "[发送中]",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.sp,
                ),
              ),
            ),
            Container(
              child: Text(
                "${lastmsg}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 25.sp,
                ),
              ),
            )
          ],
        );
      case 2:
        return Container(
          child: Text(
            "${lastmsg}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black45,
              fontSize: 25.sp,
            ),
          ),
        );
      case 3:
        return Row(
          children: [
            Container(
              child: Text(
                "[发送失败]",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.sp,
                ),
              ),
            ),
            Container(
              child: Text(
                lastmsg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 25.sp,
                ),
              ),
            )
          ],
        );
      case 6:
        return Container(
          child: Text(
            v2timMsg.isSelf == true ? "你撤回了一条消息" : "对方撤回了一条消息",
            style: TextStyle(
              color: Colors.black45,
              fontSize: 25.sp,
            ),
          ),
        );
      default:
        return Container();
    }
  }

  //页面跳转
  onTap(V2TimConversation item) {
    Application.router.navigateTo(
      context,
      "/chatDetail",
      transition: TransitionType.inFromRight,
      routeSettings: RouteSettings(
        arguments: {
          "userID": item.userID,
          "showName": item.showName,
        },
      ),
    );
  }
}
