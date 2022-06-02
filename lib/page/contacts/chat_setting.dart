import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/page/contacts/component/block_person.dart';
import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/page/widget/common_dialog.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:my_chat/utils/event_bus.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class ChatSetting extends StatefulWidget {
  String? userID;
  ChatSetting({
    Key? key,
    this.userID,
  }) : super(key: key);

  @override
  State<ChatSetting> createState() => _ChatSettingState();
}

class _ChatSettingState extends State<ChatSetting> {
  V2TimConversation? conversation;
  var flag = false;
  @override
  void initState() {
    super.initState();

    getconversationInfo();

    //修改备注 刷新
    eventBus.on<NoticeEvent>().listen((event) {
      if (mounted) {
        if (event.notice == Notice.remark) {
          getconversationInfo();
        }
      }
    });
  }

  // 获取单个会话
  getconversationInfo() async {
    conversation = (await Chat.getConversationInfo(false, widget.userID))!;
    if (conversation != null) {
      if (conversation!.isPinned!) {
        flag = true;
      }
    }
    setState(() {});
  }

  //删除弹窗
  deleteDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return CommonDialog(
          title: "删除联系人",
          subtitle: "将该联系人删除，将同时删除与该联系人的聊天记录",
          sure: "删除",
          clickCallback: () {
            Provider.of<Friend>(context, listen: false)
                .deleteFromFriendList(widget.userID, context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backBtn(context),
        title: Text("聊天设置"),
      ),
      body: SingleChildScrollView(
        child: conversation == null
            ? Container(
                child: Text("查不到改用户"),
              )
            : Column(
                children: [
                  Container(height: 25.h),
                  avatorAdd(),
                  Container(height: 25.h),
                  remarks(),
                  Container(height: 25.h),
                  chatTop(),
                  BlockPerson(userID: widget.userID),
                  Container(height: 25.h),
                  report(),
                  Container(height: 25.h),
                  deleteFriend(),
                ],
              ),
      ),
    );
  }

  // 头像 和 点击创建群聊
  Widget avatorAdd() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 20.r),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Avatar(
                isSelf: false,
                size: 80.r,
                faceUrl: conversation!.faceUrl,
              ),
              Container(
                padding: EdgeInsets.only(top: 10.r),
                child: Text(
                  "${conversation!.showName}",
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.black45,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 20.r),
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.add,
              size: 30.r,
            ),
          )
        ],
      ),
    );
  }

  //备注
  Widget remarks() {
    return CustomTap(
      onTap: () {
        Application.router.navigateTo(
          context,
          "/remark",
          transition: TransitionType.inFromRight,
          routeSettings: RouteSettings(
            arguments: {
              "userID": widget.userID,
            },
          ),
        );
      },
      tapColor: HexColor.fromHex('#f5f5f5'),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 20.r),
        child: Row(
          children: [
            Text(
              "备注",
              style: TextStyle(
                fontSize: 30.sp,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  //聊天置顶
  Widget chatTop() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 10.r),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            "置顶聊天",
            style: TextStyle(fontSize: 30.sp),
          ),
          const Spacer(),
          Transform.scale(
            scale: 0.75,
            child: CupertinoSwitch(
              value: flag,
              trackColor: Colors.black26,
              onChanged: (value) {
                Provider.of<Chat>(context, listen: false)
                    .pinConversation(conversation!.conversationID, value);
                flag = value;
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  //举报
  Widget report() {
    return CustomTap(
      onTap: () {},
      tapColor: HexColor.fromHex('#f5f5f5'),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 20.r),
        child: Row(
          children: [
            Text(
              "投诉",
              style: TextStyle(
                fontSize: 30.sp,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  //删除好友
  Widget deleteFriend() {
    return CustomTap(
      onTap: () {
        deleteDialog();
      },
      tapColor: HexColor.fromHex('#f5f5f5'),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 20.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "删除好友",
              style: TextStyle(
                color: Colors.red,
                fontSize: 30.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
