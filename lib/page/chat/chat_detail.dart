import 'package:audioplayers/audioplayers.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:extended_list/extended_list.dart';
import 'package:fluro/fluro.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/page/chat/component/msg_custom.dart';
import 'package:my_chat/page/chat/component/msg_emo.dart';
import 'package:my_chat/page/chat/component/input_box.dart';
import 'package:my_chat/page/chat/component/msg_image.dart';
import 'package:my_chat/page/chat/component/msg_text.dart';
import 'package:my_chat/page/chat/component/msg_video.dart';
import 'package:my_chat/page/chat/component/msg_voice.dart';

import 'package:my_chat/page/widget/agreement_dialog.dart';

import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:my_chat/utils/constant.dart';
import 'package:my_chat/utils/event_bus.dart';

import 'package:my_chat/utils/relative_date_format.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

import 'dart:async';

import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatDetailPage extends StatefulWidget {
  String? userID;
  String? showName;
  ChatDetailPage({
    Key? key,
    this.userID,
    this.showName,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  //下拉刷新控制器
  final EasyRefreshController _controller = EasyRefreshController();

  ScrollController scrollController = ScrollController();

  List<V2TimMessage> c2CMsgList = []; //历史消息

  AudioPlayer audioPlayer = AudioPlayer();

  var userID;

  @override
  void initState() {
    super.initState();

    userID = widget.userID;
    Provider.of<Chat>(context, listen: false).getC2CMsgList(userID);
    Provider.of<Chat>(context, listen: false).setUserId(userID);
    Provider.of<Chat>(context, listen: false).chatPage(true);
    Provider.of<Chat>(context, listen: false).clearC2CMsgUnRead(userID);

    //更新聊天页面
    eventBus.on<UpdateChatPageEvent>().listen((event) {
      if (mounted) {
        c2CMsgList = event.c2CMsgList;
        setState(() {});
        _controller.finishLoad(success: true, noMore: false);
      }
    });
    setState(() {});
  }

  //离开聊天界面
  @override
  void deactivate() {
    Provider.of<Chat>(context, listen: false).chatPage(false);
    super.deactivate();
  }

  @override
  void dispose() {
    // _animationController.dispose();
    audioPlayer.dispose();
    scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: backBtn(context),
        centerTitle: true,
        title: Text(
          "${widget.showName}",
          style: TextStyle(fontSize: 35.sp),
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.more_horiz,
                color: Colors.black,
              ),
              onPressed: () {
                Application.router.navigateTo(
                  context,
                  "/chatSetting",
                  transition: TransitionType.inFromRight,
                  routeSettings: RouteSettings(
                    arguments: {
                      "userID": widget.userID,
                    },
                  ),
                );
              }),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          //点击空白关闭底部键盘
          eventBus.fire(CloseButtonKeyEvent(true));
        },
        child: Container(
          color: HexColor.fromHex('#EDEDED'),
          child: Column(
            children: [
              ScrollConfiguration(
                behavior: CusBehavior(),
                child: Expanded(
                  // key: _myKey,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      print(constraints.maxHeight);
                      eventBus.fire(ChatPageHightEvent(constraints.maxHeight));
                      return RepaintBoundary(
                        child: EasyRefresh(
                          enableControlFinishLoad: true,
                          controller: _controller,
                          footer: Commons.customFooter(),
                          child: ExtendedListView.builder(
                            addAutomaticKeepAlives: true,
                            cacheExtent: 5000000,
                            extendedListDelegate:
                                ExtendedListDelegate(closeToTrailing: true),
                            controller: scrollController,
                            reverse: true,
                            itemCount: c2CMsgList.length,
                            itemBuilder: (BuildContext context, int index) {
                              //单个消息
                              return chatItem(c2CMsgList[index], index);
                            },
                          ),
                          onLoad: () async {
                            Future.delayed(const Duration(seconds: 1), () {
                              Provider.of<Chat>(context, listen: false)
                                  .getC2CHistoryMsgList(userID, c2CMsgList);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              SafeArea(
                child: Container(
                  child: ButtonInputBox(userID: userID),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //单个消息布局
  Widget chatItem(V2TimMessage item, index) {
    bool shouTime = false;

    var time = RelativeDateFormat.chatTime(item.timestamp!);
    //是否显示时间
    if (index + 1 == c2CMsgList.length) {
      shouTime = true;
    } else {
      var m = (item.timestamp! - c2CMsgList[index + 1].timestamp!) / 60;
      if (m > 5) {
        shouTime = true;
      }
    }
    return Container(
      child: Container(
        key: UniqueKey(),
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            shouTime == true
                ? Container(
                    padding: EdgeInsets.only(bottom: 20.r),
                    child: Text(
                      "$time",
                      style: TextStyle(
                        color: Colors.black26,
                        fontSize: 22.sp,
                      ),
                    ),
                  )
                : Container(),
            msgContent(item),
          ],
        ),
      ),
    );
  }

  //消息
  Widget msgContent(V2TimMessage item) {
    switch (item.status) {
      case 6:
        return Text(
          item.isSelf == true ? "你撤回了一条消息" : "对方撤回了一条消息",
          style: TextStyle(
            color: Colors.black38,
            fontSize: 25.sp,
          ),
        );
      default:
        return content(item);
    }
  }

  //消息内容
  Widget content(V2TimMessage item) {
    switch (item.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        // textMsg = "[文本]";
        return TextMsg(item: item);

      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        // textMsg = "[自定义消息]";
        return MsgCustom(item: item);

      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        // textMsg = "[图片]";
        return MsgImage(item: item);

      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        // textMsg = "[语音]";
        return MsgVoice(item: item, audioPlayer: audioPlayer);

      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        // textMsg = "[视频]";
        return MsgVideo(item: item);

      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        // textMsg = "[文件]";
        return Container();

      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        // textMsg = "[表情包]";
        return MsgEmo(item: item);

      default:
        return Container();
    }
  }
}
