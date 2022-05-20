import 'package:audioplayers/audioplayers.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/model/tencent_api_resp.dart';
import 'package:my_chat/utils/error_tips.dart';
import 'package:my_chat/utils/event_bus.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_response_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/user_info_allow_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class Chat with ChangeNotifier {
  //
  var pageUserId;
  bool ischatPage = false;
  List<V2TimMessage> _c2CMsgList = []; //消息
  List<V2TimConversation> _currentMessageList = []; //会话列表
  int _unreadCount = 0; //未读总数
  List<V2TimFriendInfo> _friendList = []; //好友列表
  List<V2TimUserFullInfo> _usersInfo = []; //用户信息
  List<V2TimUserFullInfo> _selfInfo = []; //自己的信息
  List<V2TimFriendInfoResult> _friendInfo = []; //指定好友的信息
  List<V2TimFriendInfo> _blackList = []; //黑名单
  int _friendApplicationUnreadCount = 0; //申请好友未读数
  List<V2TimFriendApplication?>? _applicationList = []; //申请列表
  V2TimConversation? _v2timConversation; //单个会话信息

  List<V2TimMessage> get c2CMsgList => _c2CMsgList;
  List<V2TimConversation> get currentMessageList => _currentMessageList;
  int get unreadCount => _unreadCount;
  List<V2TimFriendInfo> get friendList => _friendList;
  List<V2TimUserFullInfo> get usersInfo => _usersInfo;
  List<V2TimUserFullInfo> get selfInfo => _selfInfo;
  List<V2TimFriendInfoResult> get friendInfo => _friendInfo;
  List<V2TimFriendInfo> get blackList => _blackList;
  int get friendApplicationUnreadCount => _friendApplicationUnreadCount;
  List<V2TimFriendApplication?>? get applicationList => _applicationList;
  V2TimConversation? get v2timConversation => _v2timConversation;

  //聊天界面的用户 和谁在聊天
  setUserId(userID) {
    pageUserId = userID;
  }

  //是否在聊天界面
  chatPage(bool e) {
    ischatPage = e;
  }

  //获取会话列表
  getConversationList() async {
    V2TimValueCallback<V2TimConversationResult> data = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversationList(count: 100, nextSeq: "0");

    if (data.data!.conversationList!.isNotEmpty) {
      _currentMessageList =
          data.data!.conversationList!.cast<V2TimConversation>();
    } else {
      _currentMessageList = [];
    }
    notifyListeners();
  }

  //获取未读的总数
  getUnreadCount() async {
    V2TimValueCallback<int> data = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .getTotalUnreadMessageCount();

    _unreadCount = data.data!.bitLength;

    notifyListeners();
  }

  //置顶会话
  pinConversation(String conversationID, bool isPinned) async {
    await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .pinConversation(conversationID: conversationID, isPinned: isPinned);
  }

  //删除会话
  deleteConversation(String conversationID) async {
    await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .deleteConversation(conversationID: conversationID);
    getConversationList();
  }

  //获取指定 会话的信息
  getConversation(conversationID) async {
    V2TimValueCallback<V2TimConversation> res = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversation(conversationID: "c2c_$conversationID");
    if (res.data != null) {
      _v2timConversation = res.data;
    }
    notifyListeners();
  }

  //接收 消息
  recvNewMessage(V2TimMessage newMessage) {
    // AudioCache player = AudioCache();
    // player.play('mp3/13203.wav');
    if (ischatPage) {
      if (newMessage.userID == pageUserId) {
        //消息去重
        if (newMessage.msgID != _c2CMsgList[0].msgID) {
          _c2CMsgList.insert(0, newMessage);
          eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));
          clearC2CMsgUnRead(pageUserId);
        }
      }
    }
  }

  // 清空单聊未读消息数
  clearC2CMsgUnRead(userID) async {
    print(userID);
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .markC2CMessageAsRead(userID: userID);
    if (res.code == 0) {
      getConversationList();
    }
  }

  //发送 文本 消息
  sendTextMsg(String msgtext, userID, isAm) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createTextMessage(text: msgtext);
    String id = createMessage.data!.id!; // 返回的消息创建id

    _c2CMsgList.insert(0, createMessage.data!.messageInfo!);
    eventBus.fire(UpdateChatPageEvent(_c2CMsgList, isAm));

    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id, // 将消息创建id传递给
              receiver: userID,
              groupID: "",
            );

    if (res.data != null) {
      for (int i = 0; i < _c2CMsgList.length; i++) {
        if (_c2CMsgList[i].id == res.data!.id) {
          _c2CMsgList[i] = res.data!;
          eventBus.fire(UpdateChatPageEvent(_c2CMsgList, isAm));
        }
      }
    }
  }

  //发送 表情 消息
  sendFaceMsg(int index, String msg, userID) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createFaceMessage(index: index, data: msg);
    String id = createMessage.data!.id!; // 返回的消息创建id

    _c2CMsgList.insert(0, createMessage.data!.messageInfo!);
    eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));

    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id, // 将消息创建id传递给
              receiver: userID,
              groupID: "",
            );

    if (res.data != null) {
      for (int i = 0; i < _c2CMsgList.length; i++) {
        if (_c2CMsgList[i].id == res.data!.id) {
          _c2CMsgList[i] = res.data!;
          eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));
        }
      }
    }
  }

  //发送 图片 消息
  sendImageMsg(String imagePath, userID) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createImageMessage(imagePath: imagePath);
    String id = createMessage.data!.id!; // 返回的消息创建id

    _c2CMsgList.insert(0, createMessage.data!.messageInfo!);
    eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));

    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id, // 将消息创建id传递给
              receiver: userID,
              groupID: "",
            );

    if (res.data != null) {
      for (int i = 0; i < _c2CMsgList.length; i++) {
        if (_c2CMsgList[i].id == res.data!.id) {
          _c2CMsgList[i] = res.data!;
          eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));
        }
      }
    }
  }

  //发送 视频 消息
  sendVideoMsg(String videoFilePath, String type, int duration,
      String snapshotPath, userID) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createVideoMessage(
              videoFilePath: videoFilePath,
              type: type,
              duration: duration,
              snapshotPath: snapshotPath,
            );
    String id = createMessage.data!.id!; // 返回的消息创建id

    _c2CMsgList.insert(0, createMessage.data!.messageInfo!);
    eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));

    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id, // 将消息创建id传递给
              receiver: userID,
              groupID: "",
            );

    if (res.data != null) {
      for (int i = 0; i < _c2CMsgList.length; i++) {
        if (_c2CMsgList[i].id == res.data!.id) {
          _c2CMsgList[i] = res.data!;
          eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));
        }
      }
    }
  }

  //发送 语言 消息
  sendSoundMsg(String soundPath, int duration, userID) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createSoundMessage(soundPath: soundPath, duration: duration);
    String id = createMessage.data!.id!; // 返回的消息创建id

    _c2CMsgList.insert(0, createMessage.data!.messageInfo!);
    eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));

    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id, // 将消息创建id传递给
              receiver: userID,
              groupID: "",
            );

    if (res.data != null) {
      for (int i = 0; i < _c2CMsgList.length; i++) {
        if (_c2CMsgList[i].id == res.data!.id) {
          _c2CMsgList[i] = res.data!;
          eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));
        }
      }
    }
  }

  //设置本地消息 用来设置语音红点未读
  setLocalCustomInt(msgID, localCustomInt) async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .setLocalCustomInt(msgID: msgID, localCustomInt: localCustomInt);
    for (int i = 0; i < _c2CMsgList.length; i++) {
      if (_c2CMsgList[i].msgID == msgID) {
        _c2CMsgList[i].localCustomInt = 1;
        break;
      }
    }
  }

  //获取单聊消息 最新的20条
  getC2CMsgList(userID) async {
    _c2CMsgList = [];
    V2TimValueCallback<List<V2TimMessage>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getMessageManager()
        .getC2CHistoryMessageList(
          userID: userID,
          count: 20,
        );
    _c2CMsgList = res.data!;
    eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));
  }

  //获取单聊历史消息
  getC2CHistoryMsgList(userID, List<V2TimMessage> msgList) async {
    if (msgList.isNotEmpty) {
      var lastMsgID = msgList[msgList.length - 1].msgID;

      V2TimValueCallback<List<V2TimMessage>> nextRes = await TencentImSDKPlugin
          .v2TIMManager
          .getMessageManager()
          .getC2CHistoryMessageList(
            userID: userID,
            count: 20,
            lastMsgID: lastMsgID,
          );
      if (nextRes.data != null) {
        _c2CMsgList.addAll(nextRes.data!);
      }
      eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));
    }
  }

  //删除某个消息
  deleteMessages(msgID) async {
    await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .deleteMessages(msgIDs: [msgID]);
    for (int i = 0; i < _c2CMsgList.length; i++) {
      if (_c2CMsgList[i].msgID == msgID) {
        _c2CMsgList.removeAt(i);
        eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));
        break;
      }
    }
  }

  //消息撤回
  revokeMessage(msgID) async {
    await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .revokeMessage(msgID: msgID);
    revoke(msgID);
  }

  //撤回 回调 修改信息
  revoke(msgID) {
    for (int i = 0; i < _c2CMsgList.length; i++) {
      if (_c2CMsgList[i].msgID == msgID) {
        _c2CMsgList[i].status = 6;
        eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));
        break;
      }
    }
  }

  /* 
    ## 自定义消息
    ## PROMPT- (不更新会话的提示类 自定义信息)
    ## CONCISE- (不更新会话的自我介绍 自定义信息)
    ## VOICECALL- (不更新未读数的语音通话 自定义信息)

  */
  sendCustomMsg(String msgtext, userID, isAm, isExcludedFromLastMessage) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createCustomMessage(data: msgtext);
    String id = createMessage.data!.id!; // 返回的消息创建id

    _c2CMsgList.insert(0, createMessage.data!.messageInfo!);
    eventBus.fire(UpdateChatPageEvent(_c2CMsgList, isAm));

    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id, // 将消息创建id传递给
              receiver: userID,
              groupID: "",
              isExcludedFromUnreadCount: true,
              isExcludedFromLastMessage: isExcludedFromLastMessage,
            );

    if (res.data != null) {
      for (int i = 0; i < _c2CMsgList.length; i++) {
        if (_c2CMsgList[i].id == res.data!.id) {
          _c2CMsgList[i] = res.data!;
          eventBus.fire(UpdateChatPageEvent(_c2CMsgList, isAm));
        }
      }
    }
  }

/* 



  



   好友关系链


 */

  // 获取好友列表
  getFriendList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getFriendshipManager()
        .getFriendList();
    if (res.data != null) {
      _friendList = res.data!;
      notifyListeners();
    } else {
      _friendList = [];
    }
  }

  //查询 用户信息
  getUsersInfo(userIDList, context) async {
    _usersInfo = [];
    V2TimValueCallback<List<V2TimUserFullInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getUsersInfo(userIDList: [userIDList]);
    if (res.data != null) {
      _usersInfo = res.data!;

      notifyListeners();
    } else {
      _usersInfo = [];
    }
    Application.router.navigateTo(
      context,
      "/friendInfoPage",
      transition: TransitionType.inFromRight,
    );
  }

  //查询好友信息
  getFriendsInfo(userIDList, context) async {
    _friendInfo = [];
    V2TimValueCallback<List<V2TimFriendInfoResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendsInfo(userIDList: [userIDList]);
    print(res.data!.length);
    if (res.data != null) {
      _friendInfo = res.data!;
      print("查询到好友");

      notifyListeners();
    } else {
      _friendInfo = [];
    }
    Application.router.navigateTo(
      context,
      "/friendInfoPage",
      transition: TransitionType.inFromRight,
    );
  }

  //添加好友
  addFriend(userID, context, addWording) async {
    EasyLoading.show(status: '正在发送...');
    V2TimValueCallback<V2TimFriendOperationResult> res =
        await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().addFriend(
              userID: userID,
              addType: FriendTypeEnum.V2TIM_FRIEND_TYPE_BOTH,
              addWording: addWording,
            );
    if (res.data!.resultCode == 0) {
      Fluttertoast.showToast(msg: "发送成功");
    } else {
      ErrorTips.errorMsg(res.data!.resultCode);
    }
    EasyLoading.dismiss();
    Application.router.pop(context);
  }

  //删除 单个 好友
  deleteFromFriendList(userID, context) async {
    V2TimValueCallback<List<V2TimFriendOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .deleteFromFriendList(
                userIDList: [userID],
                deleteType: FriendTypeEnum.V2TIM_FRIEND_TYPE_SINGLE);
    if (res.data != null) {
      deleteConversation("c2c_$userID");
      Application.router.navigateTo(
        context,
        "/bottomNav",
        clearStack: true,
        transition: TransitionType.inFromRight,
      );
    } else {
      Fluttertoast.showToast(msg: "删除失败");
    }
  }

  //设置自己的 资料
  setSelfInfo(TencentUserInfoResp userinfo) async {
    V2TimUserFullInfo userIF = V2TimUserFullInfo();
    userIF.nickName = userinfo.nickname;
    userIF.faceUrl = userinfo.figureurlQq1;
    userIF.gender = userinfo.genderType;
    userIF.allowType = AllowType.V2TIM_FRIEND_NEED_CONFIRM;

    V2TimCallback res =
        await TencentImSDKPlugin.v2TIMManager.setSelfInfo(userFullInfo: userIF);
  }

  //查询自己的信息
  getSelfInfo(selfInfoID) async {
    V2TimValueCallback<List<V2TimUserFullInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getUsersInfo(userIDList: [selfInfoID]);
    if (res.data != null) {
      _selfInfo = res.data!;
      notifyListeners();
    } else {
      _selfInfo = [];
    }
  }

  //获取黑名单
  getBlackList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getFriendshipManager()
        .getBlackList();
    if (res.data != null) {
      _blackList = res.data!;
      notifyListeners();
    }
  }

  //获取好友申请列表
  getFriendApplicationList() async {
    V2TimValueCallback<V2TimFriendApplicationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendApplicationList();
    if (res.data != null) {
      _friendApplicationUnreadCount = res.data!.unreadCount!;
      _applicationList = res.data!.friendApplicationList;
    }
    notifyListeners();
  }

  // 同意好友申请
  acceptFriendApplication(userID, context) async {
    EasyLoading.show(status: '加载中...');
    V2TimValueCallback<V2TimFriendOperationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .acceptFriendApplication(
              responseType:
                  FriendResponseTypeEnum.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD,
              type: FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_COME_IN,
              userID: userID,
            );
    if (res.data!.resultCode == 0) {
      Fluttertoast.showToast(msg: "添加成功");
      sendTextMsg("我通过了你的请求", userID, false);
      //发送不更新会话的消息
      sendCustomMsg("PROMPT-你们已经是好友了", userID, false, true);
      Application.router.navigateTo(
        context,
        "/bottomNav",
        clearStack: true,
        transition: TransitionType.inFromRight,
      );
    }
    EasyLoading.dismiss();
  }

  //拒绝好友申请
  refuseFriendApplication(userID) async {
    await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .refuseFriendApplication(
          type: FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_COME_IN,
          userID: userID,
        );
  }

  //设置好友申请已读
  setFriendApplicationRead() async {
    await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .setFriendApplicationRead();
    getFriendApplicationList();
  }

  //修改好友信息 备注等信息
  setFriendInfo(userID, friendRemark) async {
    await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .setFriendInfo(userID: userID, friendRemark: friendRemark);
  }
}
