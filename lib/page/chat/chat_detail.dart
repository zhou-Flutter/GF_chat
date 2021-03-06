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
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class ChatDetailPage extends StatefulWidget {
  String? userID;

  ChatDetailPage({
    Key? key,
    this.userID,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  //?????????????????????
  final EasyRefreshController _controller = EasyRefreshController();

  ScrollController scrollController = ScrollController();

  List<V2TimMessage> c2CMsgList = []; //????????????

  AudioPlayer audioPlayer = AudioPlayer();

  var userID;

  V2TimConversation? conversation;

  @override
  void initState() {
    super.initState();

    userID = widget.userID;

    c2CMsgList = Provider.of<Chat>(context, listen: false).c2CMsgList;
    Provider.of<Chat>(context, listen: false).setConverID(userID);
    Provider.of<Chat>(context, listen: false).chatPage(ChaPage.crc);
    Provider.of<Chat>(context, listen: false).clearC2CMsgUnRead(userID);

    //??????????????????
    eventBus.on<UpdateChatPageEvent>().listen((event) {
      if (mounted) {
        c2CMsgList = event.c2CMsgList;
        setState(() {});
        _controller.finishLoad(success: true, noMore: false);
      }
    });
    //???????????? ??????
    eventBus.on<NoticeEvent>().listen((event) {
      if (mounted) {
        if (event.notice == Notice.remark) {
          getconversationInfo();
        }
      }
    });
    getconversationInfo();
  }

  // ??????????????????
  getconversationInfo() async {
    conversation = (await Chat.getConversationInfo(false, widget.userID))!;
    setState(() {});
  }

  //??????????????????
  @override
  void deactivate() {
    Provider.of<Chat>(context, listen: false).chatPage(ChaPage.noPage);
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
          conversation == null ? "" : "${conversation!.showName}",
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
          //??????????????????????????????
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
                              //????????????
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
                  child: ButtonInputBox(converID: userID, isGroup: false),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //??????????????????
  Widget chatItem(V2TimMessage item, index) {
    bool shouTime = false;

    var time = RelativeDateFormat.chatTime(item.timestamp!);
    //??????????????????
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

  //??????
  Widget msgContent(V2TimMessage item) {
    switch (item.status) {
      case 6:
        return Text(
          item.isSelf == true ? "????????????????????????" : "???????????????????????????",
          style: TextStyle(
            color: Colors.black38,
            fontSize: 25.sp,
          ),
        );
      default:
        return content(item);
    }
  }

  //????????????
  Widget content(V2TimMessage item) {
    switch (item.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        // textMsg = "[??????]";
        return TextMsg(item: item, isGroup: false);

      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        // textMsg = "[???????????????]";
        return MsgCustom(item: item);

      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        // textMsg = "[??????]";
        return MsgImage(item: item, isGroup: false);

      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        // textMsg = "[??????]";
        return MsgVoice(item: item, audioPlayer: audioPlayer, isGroup: false);

      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        // textMsg = "[??????]";
        return MsgVideo(item: item, isGroup: false);

      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        // textMsg = "[??????]";
        return Container();

      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        // textMsg = "[?????????]";
        return MsgEmo(item: item, isGroup: false);

      default:
        return Container();
    }
  }
}
