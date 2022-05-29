import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';

import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/init_provider.dart';
import 'package:my_chat/provider/login_provider.dart';
import 'package:my_chat/provider/trtc_provider.dart';
import 'package:my_chat/utils/event_bus.dart';
import 'package:provider/provider.dart';

class VoiceCallPage extends StatefulWidget {
  VoiceCallPage({Key? key}) : super(key: key);

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  var callTime = 0;
  var inviteId;
  var selfId;
  CallStatus callStatus = CallStatus.nocall;
  @override
  void initState() {
    super.initState();
    Provider.of<Trtc>(context, listen: false).floatHide();
    selfId = Provider.of<Login>(context, listen: false).selfId;

    //接收是否有滑块激活
    eventBus.on<NoticeEvent>().listen((event) {
      if (mounted) {
        if (event.notice == Notice.voicePage) {
          Application.router.pop(context);
        }
      }
    });
  }

  //页面消失
  @override
  void deactivate() {
    super.deactivate();
    Provider.of<Trtc>(context, listen: false).floatOpen();
  }

  //页面销毁
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    callTime = context.watch<Trtc>().callTime;
    inviteId = context.watch<Trtc>().inviteID;
    callStatus = context.watch<Trtc>().callStatus;
    return Container(
      color: Colors.black87,
      child: Column(
        children: [
          SafeArea(
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Application.router.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.all(30.r),
                    width: 70.r,
                    height: 70.r,
                    decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(20.r)),
                    child: Icon(
                      Icons.close_fullscreen,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 120.h,
          ),
          Container(
            child: Avatar(isSelf: true, size: 200.r),
          ),
          Container(
            padding: EdgeInsets.all(30.r),
            child: Text(
              "flutter",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.sp,
              ),
            ),
          ),
          const Spacer(),
          bottomTool()
        ],
      ),
    );
  }

  //底部工具栏 接听 挂断 麦克风等
  Widget bottomTool() {
    switch (callStatus) {
      case CallStatus.receiveing:
        return call();
      case CallStatus.sendering:
        return calling();
      case CallStatus.calling:
        return calling();
      default:
        return Container();
    }
  }

  //电话 等待接听
  Widget call() {
    return Column(
      children: [
        Text(
          "等待接听...",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.sp,
          ),
        ),
        Container(
          padding: EdgeInsets.all(30.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  print("拒绝通话");
                  Provider.of<Trtc>(context, listen: false)
                      .rejectInvite(inviteId, "挂断电话", context);
                },
                child: Container(
                  margin: EdgeInsets.all(30.r),
                  width: 130.r,
                  height: 130.r,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30.r)),
                  child: Icon(
                    IconData(0xe670, fontFamily: "icons"),
                    size: 60.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 100.w),
              InkWell(
                onTap: () {
                  print("同意通话");
                  Provider.of<Trtc>(context, listen: false)
                      .acceptInvite(selfId);
                },
                child: Container(
                  margin: EdgeInsets.all(30.r),
                  width: 130.r,
                  height: 130.r,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(30.r)),
                  child: Icon(
                    IconData(0xe963, fontFamily: "icons"),
                    size: 60.sp,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  //接听中 发送者
  Widget calling() {
    return Column(
      children: [
        Text(
          callStatus == CallStatus.sendering ? "正在呼叫。。" : "00 : ${callTime}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.sp,
          ),
        ),
        Container(
          padding: EdgeInsets.all(30.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(30.r),
                width: 130.r,
                height: 130.r,
                decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(30.r)),
                child: Icon(
                  IconData(0xe6a8, fontFamily: "icons"),
                  size: 60.sp,
                  color: Colors.white,
                ),
              ),
              InkWell(
                onTap: () {
                  if (callStatus == CallStatus.calling) {
                    //如果在接听中，则是挂断电话
                    Provider.of<Trtc>(context, listen: false).exitRoom();
                  } else {
                    //如果在发送中，则是取消发送信令
                    Provider.of<Trtc>(context, listen: false).creanlInvite();
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(30.r),
                  width: 130.r,
                  height: 130.r,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30.r)),
                  child: Icon(
                    IconData(0xe670, fontFamily: "icons"),
                    size: 60.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(30.r),
                width: 130.r,
                height: 130.r,
                decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(30.r)),
                child: Icon(
                  IconData(0xe71c, fontFamily: "icons"),
                  size: 60.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
