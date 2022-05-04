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
import 'package:my_chat/page/widget.dart/avatar.dart';
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
  late List<ItemModel> menuItems;
  final CustomPopupMenuController _controller = CustomPopupMenuController();

  List<V2TimConversation> currentMessageList = [];

  List<V2TimUserFullInfo> selfInfo = [];

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

    Provider.of<Chat>(context, listen: false).getConversationList();
    selfInfo = Provider.of<Chat>(context, listen: false).selfInfo;
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

  _onRefresh() {
    //下拉刷新
    Provider.of<Chat>(context, listen: false).getConversationList();
    print("下拉刷新");
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
          CustomPopupMenu(
            child: Container(
              child: Icon(
                IconData(0xe635, fontFamily: "icons"),
                color: Colors.black87,
                size: 40.r,
              ),
              padding: EdgeInsets.symmetric(horizontal: 35.r),
            ),
            menuBuilder: () => ClipRRect(
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
                                      margin: EdgeInsets.only(
                                          left: 20.r, right: 20.r),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20.r),
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
            ),
            pressType: PressType.singleClick,
            verticalMargin: -10,
            controller: _controller,
          ),
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
                    })
          ],
        ),
      ),
    );
  }

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
    var elemType = item.lastMessage!.elemType;
    var lastmsg = "";
    switch (elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        lastmsg = item.lastMessage!.textElem!.text!;
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

    return Container(
      child: SliderItem(
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
            )),
      ),
    );
  }

  //页面跳转
  onTap(V2TimConversation item) {
    Application.router.navigateTo(
      context,
      "/chatDetail",
      transition: TransitionType.inFromRight,
      routeSettings: RouteSettings(
        arguments: {
          "item": item,
        },
      ),
    );
  }
}
