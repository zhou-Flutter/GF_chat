import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_floating/floating/assist/floating_slide_type.dart';
import 'package:flutter_floating/floating/floating.dart';
import 'package:flutter_floating/floating/listener/floating_listener.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/page/floating/floating_window.dart';
import 'package:my_chat/page/voice_call/voice_call_page.dart';
import 'package:my_chat/provider/init_im_sdk_provider.dart';
import 'package:my_chat/utils/GenerateTestUserSig.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:my_chat/utils/event_bus.dart';
import 'package:my_chat/utils/generate_test_user_sig.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';

//音视频通话
class Trtc with ChangeNotifier {
  late TRTCCloud trtcCloud;
  var userInfo = {}; //用户信息
  var meetId;
  late Floating floatingOne;
  Timer? _timer1;
  int _callTime = 0; //通话时长
  var _inviteID; //信令ID
  CallStatus _callStatus = CallStatus.nocall; //通话状态
  int quality = TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;
  var userId; //对方的Id
  var selfId; // 自己的id
  int _roomId = 123;

  int get callTime => _callTime;
  String get inviteID => _inviteID;
  CallStatus get callStatus => _callStatus;

  //初始化房间
  // iniRoom(userID) async {
  //   userId = userID;

  //   enterRoom(userID);
  // }

  //初始化  加入房间
  enterRoom(userID, selfID) async {
    userId = userID;
    selfId = selfID;
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    trtcCloud.registerListener(onRtcListener);

    userInfo['userSig'] = await GenerateTestUserSig.genTestSig(selfId);

    await trtcCloud.enterRoom(
        TRTCParams(
          sdkAppId: GenerateTestUserSig.sdkAppId,
          userId: selfId,
          userSig: userInfo['userSig'],
          role: TRTCCloudDef.TRTCRoleAnchor,
          roomId: _roomId,
        ),
        TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL);
    print("初始化加入房间");

    initData();

    sendInviteMsg();
  }

  //被邀请者
  addRoom() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    trtcCloud.registerListener(onRtcListener);

    userInfo['userSig'] = await GenerateTestUserSig.genTestSig(selfId);

    await trtcCloud.enterRoom(
        TRTCParams(
          sdkAppId: GenerateTestUserSig.sdkAppId,
          userId: selfId,
          userSig: userInfo['userSig'],
          role: TRTCCloudDef.TRTCRoleAnchor,
          roomId: _roomId,
        ),
        TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL);
    print("被邀请者初始化加入房间");

    initData();
  }

  initData() async {
    //开启本地音频的采集和上行
    await trtcCloud.startLocalAudio(quality);
  }

  //设置监听
  onRtcListener(type, param) async {
    print("开始监听");
    if (type == TRTCCloudListener.onError) {
      if (param['errCode'] == -1308) {
        print('Failed to start screen recording');
      } else {
        print(param['errMsg']);
      }
    }
    //加入房间成功
    if (type == TRTCCloudListener.onEnterRoom) {
      print('加入房间');
      if (param > 0) {
        print('exit room success');
      }
    }

    //离开房间
    if (type == TRTCCloudListener.onExitRoom) {
      print('离开房间');
      exitRoom();
    }

    //被邀请者加入房间
    if (type == TRTCCloudListener.onRemoteUserEnterRoom) {
      print('被邀请者加入房间');
    }
    //被邀请者离开房间
    if (type == TRTCCloudListener.onRemoteUserLeaveRoom) {
      print('被邀请者离开房间');
      exitRoom();
    }
    //首帧本地音频数据已经被送出
    if (type == TRTCCloudListener.onSendFirstLocalAudioFrame) {
      print('首帧本地音频数据已经被送出');
    }
  }

  //退出房间
  exitRoom() {
    trtcCloud.exitRoom();
    _callStatus = CallStatus.nocall;
    eventBus.fire(NoticeEvent(Notice.voicePage));
    floatHide();
    notifyListeners();
  }

  //初始化 全局悬浮窗
  float() async {
    floatingOne = floatingManager.createFloating(
      "1",
      Floating(
        MyChatApp.navigatorKey,
        FloatingWindow(),
        slideType: FloatingSlideType.onRightAndTop,
        height: 80,
        width: 80,
        top: 100,
        slideTopHeight: 50,
        isShowLog: false,
        slideBottomHeight: 100,
      ),
    );
    var oneListener = FloatingListener()
      ..openListener = () {
        print('显示1');
      }
      ..closeListener = () {
        print('关闭1');
      }
      ..downListener = (x, y) {
        Application.router.navigateTo(
          MyChatApp.navigatorKey.currentState!.context,
          "/voiceCallPage",
          transition: TransitionType.inFromRight,
        );
      };
    floatingOne.addFloatingListener(oneListener);
  }

  //获取通话roomId  ，接收到有通话信令，跳转到 接受通话界面
  receiveNewInvita(inviteId, data) async {
    if (_callStatus == CallStatus.nocall) {
      _inviteID = inviteId;
      _roomId = int.parse(data);

      _callStatus = CallStatus.receiveing;
      Application.router.navigateTo(
        MyChatApp.navigatorKey.currentState!.context,
        "/voiceCallPage",
        transition: TransitionType.inFromRight,
      );
    } else {
      //该账号有通话
      await TencentImSDKPlugin.v2TIMManager
          .getSignalingManager()
          .reject(inviteID: inviteId, data: data);
    }
  }

  //发送信令消息 用来进行语音聊天
  sendInviteMsg() async {
    EasyLoading.show(status: '正在呼叫...');
    V2TimValueCallback<String> res = await TencentImSDKPlugin.v2TIMManager
        .getSignalingManager()
        .invite(invitee: userId, data: "$_roomId", onlineUserOnly: true);

    _inviteID = res.data;
    _callStatus = CallStatus.sendering;
    Application.router.navigateTo(
      MyChatApp.navigatorKey.currentState!.context,
      "/voiceCallPage",
      transition: TransitionType.inFromRight,
    );
    EasyLoading.dismiss();
    notifyListeners();
  }

  //接受信令 开始通话
  acceptInvite(selfID) async {
    selfId = selfID;
    await TencentImSDKPlugin.v2TIMManager
        .getSignalingManager()
        .accept(inviteID: _inviteID);
    _callStatus = CallStatus.calling;
    addRoom();
    //开始计时
    // callTimer();
    notifyListeners();
  }

  // 拒绝信令 通话结束
  rejectInvite(inviteId, data, context) async {
    await TencentImSDKPlugin.v2TIMManager
        .getSignalingManager()
        .reject(inviteID: inviteId, data: data);

    _callStatus = CallStatus.nocall;
    floatHide();
    notifyListeners();
  }

  //取消发送信令
  creanlInvite() async {
    //退出房间
    trtcCloud.exitRoom();
    //取消发送信令
    await TencentImSDKPlugin.v2TIMManager
        .getSignalingManager()
        .cancel(inviteID: _inviteID);
    _callStatus = CallStatus.nocall;
    //关闭悬浮窗
    floatHide();
  }

  //挂断电话
  hangUp() {
    _callStatus = CallStatus.nocall;
    eventBus.fire(NoticeEvent(Notice.voicePage));
    floatHide();
    notifyListeners();
  }

  //监听 接受信令 回调
  acceptInviteBack() {
    //信令被接受，开始计时
    _callStatus = CallStatus.calling;
    callTimer();
  }

  //监听 拒绝信令 回调
  rejectInviteBack() {
    //销毁通话页面
    _callStatus = CallStatus.nocall;
    eventBus.fire(NoticeEvent(Notice.voicePage));
    floatHide();
    notifyListeners();
  }

  //监听 信令被取消 回调
  onInvitationCancelled() {
    //销毁通话页面
    _callStatus = CallStatus.nocall;
    eventBus.fire(NoticeEvent(Notice.voicePage));
    floatHide();
    notifyListeners();
  }

  //隐藏悬浮窗
  floatHide() {
    floatingOne.hideFloating();
  }

  //显示悬浮窗
  floatOpen() {
    if (_callStatus != CallStatus.nocall) {
      floatingOne.open();
    }
  }

  //通话时长
  callTimer() {
    _timer1 = Timer.periodic(
      const Duration(seconds: 1),
      (_timer1) => {
        print("计时开始"),
        _callTime++,
        notifyListeners(),
      },
    );
  }
}

//通话状态
enum CallStatus {
  nocall, //无 通话
  calling, //通话中
  sendering, //  发送等待
  receiveing, // 接收等待
}
