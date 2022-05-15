import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_floating/floating/assist/floating_slide_type.dart';
import 'package:flutter_floating/floating/floating.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/model/tencent_api_resp.dart';
import 'package:my_chat/page/communal/communal.dart';
import 'package:my_chat/page/floating/floating_window.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/trtc_provider.dart';
import 'package:my_chat/utils/generate_test_user_sig.dart';
import 'package:my_chat/utils/locator.dart';
import 'package:my_chat/utils/tencent.dart';
import 'package:nim_core/nim_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_kit/tencent_kit.dart';

class InitIMSDKProvider with ChangeNotifier {
  final String _TENCENT_APPID = '102005320'; //腾讯QQ APPID
  LoginResp? _loginResp; //qq登录信息
  String _userId = ""; //用户ID
  TencentUserInfoResp? userInfo; //腾讯 QQ 用户信息

  String get selfId => _userId;
  late Floating floatingOne;

  //初始化IM SDK
  initSDK(context) async {
    V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;
    await timManager.initSDK(
        sdkAppID: 1400559934,
        loglevel: LogLevelEnum.V2TIM_LOG_ERROR,
        listener: V2TimSDKListener(
          onConnecting: () {
            print("正在连接");
          },
          onConnectFailed: (code, error) {
            print("当前网络连接不可用");
          },
          onConnectSuccess: () {
            print("连接成功");
          },
          onKickedOffline: () {
            print("挤下线");
          },
          onSelfInfoUpdated: (info) {
            Provider.of<Chat>(context, listen: false).getSelfInfo(_userId);
          },
          onUserSigExpired: () {},
        ));

    //会话列表监听
    await timManager.getConversationManager().setConversationListener(
            listener: V2TimConversationListener(
          onConversationChanged: (List<V2TimConversation>? e) {
            print("绘画改变回调");
            Provider.of<Chat>(context, listen: false).getConversationList();
          },
          onNewConversation: (e) {
            print("新会话回调");
            Provider.of<Chat>(context, listen: false).getConversationList();
          },
          onSyncServerFailed: () {},
          onSyncServerFinish: () {},
          onSyncServerStart: () {},
          onTotalUnreadMessageCountChanged: (e) {
            print("未读回调");
            Provider.of<Chat>(context, listen: false).getUnreadCount();
          },
        ));

    //接受消息监听
    await timManager.getMessageManager().addAdvancedMsgListener(
          listener: V2TimAdvancedMsgListener(
            onRecvNewMessage: (v2TimMessage) {
              //接受消息
              Provider.of<Chat>(context, listen: false)
                  .recvNewMessage(v2TimMessage);
            },
            onRecvMessageRevoked: (msgID) {
              //消息撤回
              Provider.of<Chat>(context, listen: false).revoke(msgID);
            },
          ),
        );

    //注册群组消息监听器
    await TencentImSDKPlugin.v2TIMManager.addGroupListener(
      listener: V2TimGroupListener(),
    );

    //注册信令消息监听器
    await timManager.getSignalingManager().addSignalingListener(
          listener: V2TimSignalingListener(
            onReceiveNewInvitation: (inviteID, inviter, c, d, data) {
              print("收到信令");
              Provider.of<Trtc>(context, listen: false)
                  .receiveNewInvita(inviteID, data);
            },
            onInviteeAccepted: (a, b, e) {
              Provider.of<Trtc>(context, listen: false).acceptInviteBack();
            },
            onInviteeRejected: (a, b, c) {
              print("拒绝");
              Provider.of<Trtc>(context, listen: false).rejectInviteBack();
            },
            onInvitationCancelled: (a, b, c) {
              print("取消");
              Provider.of<Trtc>(context, listen: false).onInvitationCancelled();
            },
            onInvitationTimeout: (a, b) {
              print("超时");
            },
          ),
        );

    //添加好友 监听
    await timManager.getFriendshipManager().addFriendListener(
          listener: V2TimFriendshipListener(),
        );

    //注册关系链监听器
    await timManager.getFriendshipManager().setFriendListener(
      listener: V2TimFriendshipListener(
        onFriendListAdded: (e) {
          Provider.of<Chat>(context, listen: false).getFriendList();
        },
      ),
    );
  }

  //登录
  tologin(context) async {
    print(_userId);
    if (_userId == "") {
      Application.router.navigateTo(
        context,
        "/loginPage",
        clearStack: true,
        transition: TransitionType.inFromRight,
      );
    } else {
      GenerateTestUserIMSig usersig = GenerateTestUserIMSig(
        sdkappid: 1400559934,
        key: "a3e290c6599c803789611039131f2283508f2707c8da745934459f123c6b9817",
      );

      String pwdStr = usersig.genSig(identifier: _userId, expire: 86400);
      V2TimCallback data = await TencentImSDKPlugin.v2TIMManager.login(
        userID: _userId,
        userSig: pwdStr,
      );

      if (data.code != 0) {
        Fluttertoast.showToast(msg: "登录信息失效，请重新登录");
        Application.router.navigateTo(
          context,
          "/loginPage",
          clearStack: true,
          transition: TransitionType.inFromRight,
        );
        return;
      } else {
        setUserInfo(context);
        EasyLoading.dismiss();
        //登录成功
        Application.router.navigateTo(
          context,
          "/bottomNav",
          clearStack: true,
          transition: TransitionType.inFromRight,
        );
      }
    }
  }

  /*

     以下是qq登录的逻辑

   */
  //qq监听
  listenLogin(BaseResp resp, context) {
    if (resp is LoginResp) {
      _loginResp = resp;
      final String content = 'login: ${resp.openid} - ${resp.accessToken}';
      _userId = resp.openid!;
      saveUserId();
      getUserInfo(context);
    } else if (resp is ShareMsgResp) {
      final String content = 'share: ${resp.ret} - ${resp.msg}';
      Fluttertoast.showToast(msg: "分享监听中");
    }
  }

  //QQ 登录
  qqLogin() async {
    EasyLoading.show(status: '正在登录...');
    bool isqq = await Tencent.instance.isQQInstalled();
    if (isqq) {
      Tencent.instance.login(scope: <String>[TencentScope.GET_SIMPLE_USERINFO]);
    } else {
      Fluttertoast.showToast(msg: "未安装QQ");
    }
  }

  //获取用户信息
  getUserInfo(context) async {
    if ((_loginResp?.isSuccessful ?? false) &&
        !(_loginResp!.isExpired ?? true)) {
      userInfo = await Tencent.instance.getUserInfo(
        appId: _TENCENT_APPID,
        openid: _loginResp!.openid!,
        accessToken: _loginResp!.accessToken!,
      );
      if (userInfo!.isSuccessful) {
        tologin(context);
      } else {
        Fluttertoast.showToast(msg: "${userInfo!.msg}");
      }
    }
  }

  setUserInfo(context) async {
    if (userInfo != null) {
      Provider.of<Chat>(context, listen: false).setSelfInfo(userInfo!);
    }
  }

  // 获取 userId
  saveUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userId", _userId);
  }

  // 获取 userId  进行登录
  getUserID(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      _userId = prefs.getString("userId")!;
      tologin(context);
    } else {
      Application.router.navigateTo(
        context,
        "/loginPage",
        clearStack: true,
        transition: TransitionType.inFromRight,
      );
    }
  }

  /*

     以下是微信登录的逻辑

  */
  //由于微信的原因，暂无法使用微信登录

  /* 

    语音悬浮窗 处理语音通话功能
  
   */

}
