import 'package:audioplayers/audioplayers.dart';
import 'package:extended_list/extended_list.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/page/chat/component/input_box.dart';
import 'package:my_chat/page/chat/component/msg_custom.dart';
import 'package:my_chat/page/chat/component/msg_emo.dart';
import 'package:my_chat/page/chat/component/msg_image.dart';
import 'package:my_chat/page/chat/component/msg_text.dart';
import 'package:my_chat/page/chat/component/msg_video.dart';
import 'package:my_chat/page/chat/component/msg_voice.dart';
import 'package:my_chat/page/widget/agreement_dialog.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:my_chat/utils/event_bus.dart';
import 'package:my_chat/utils/relative_date_format.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class GroupChatPage extends StatefulWidget {
  String? groupID;
  String? showName;
  GroupChatPage({
    Key? key,
    this.groupID,
    this.showName,
  }) : super(key: key);

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final EasyRefreshController _controller = EasyRefreshController(); //下拉刷新控制器

  ScrollController scrollController = ScrollController();

  List<V2TimMessage> groupMsgList = []; //群聊历史消息

  AudioPlayer audioPlayer = AudioPlayer(); //语音播放

  var groupID; //群ID

  @override
  void initState() {
    super.initState();
    groupID = widget.groupID;
    // Provider.of<Chat>(context, listen: false).getGroupMsgList(groupID);
    groupMsgList = Provider.of<Chat>(context, listen: false).groupMsgList;
    Provider.of<Chat>(context, listen: false).setConverID(groupID);
    Provider.of<Chat>(context, listen: false).chatPage(ChaPage.group);
    Provider.of<Chat>(context, listen: false).clearGroupMsgUnRead(groupID);

    //更新聊天页面
    eventBus.on<UpdateGroupChatPageEvent>().listen((event) {
      if (mounted) {
        groupMsgList = event.groupMsgList;
        setState(() {});
        _controller.finishLoad(success: true, noMore: false);
      }
    });
    setState(() {});
  }

  //离开聊天界面
  @override
  void deactivate() {
    Provider.of<Chat>(context, listen: false).chatPage(ChaPage.noPage);
    super.deactivate();
  }

  @override
  void dispose() {
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
          widget.showName == " " ? "群聊" : "${widget.showName}",
          style: TextStyle(fontSize: 35.sp),
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.more_horiz,
                color: Colors.black,
              ),
              onPressed: () {
                Provider.of<Friend>(context, listen: false)
                    .getGroupMemberList(groupID, context);
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
                            cacheExtent: 5000,
                            extendedListDelegate:
                                ExtendedListDelegate(closeToTrailing: true),
                            controller: scrollController,
                            reverse: true,
                            itemCount: groupMsgList.length,
                            itemBuilder: (BuildContext context, int index) {
                              //单个消息
                              return chatItem(groupMsgList[index], index);
                            },
                          ),
                          onLoad: () async {
                            Future.delayed(const Duration(seconds: 1), () {
                              Provider.of<Chat>(context, listen: false)
                                  .getGroupHistoryMsgList(
                                      groupID, groupMsgList);
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
                  child: ButtonInputBox(converID: groupID, isGroup: true),
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
    if (index + 1 == groupMsgList.length) {
      shouTime = true;
    } else {
      var m = (item.timestamp! - groupMsgList[index + 1].timestamp!) / 60;
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
          item.isSelf == true ? "你撤回了一条消息" : "${item.nickName}撤回了一条消息",
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
        return TextMsg(item: item, isGroup: true);

      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        // textMsg = "[自定义消息]";
        return MsgCustom(item: item);

      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        // textMsg = "[图片]";
        return MsgImage(item: item, isGroup: true);

      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        // textMsg = "[语音]";
        return MsgVoice(item: item, audioPlayer: audioPlayer, isGroup: true);

      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        // textMsg = "[视频]";
        return MsgVideo(item: item, isGroup: true);

      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        // textMsg = "[文件]";
        return Container();

      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        // textMsg = "[表情包]";
        return MsgEmo(item: item, isGroup: true);

      default:
        return Container();
    }
  }
}
