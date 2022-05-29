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
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/user_info_allow_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_search_param.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class Chat with ChangeNotifier {
  //
  var converId;
  ChaPage isChaPage = ChaPage.noPage; //群聊界面 单聊界面 无
  List<V2TimMessage> _c2CMsgList = []; //消息
  List<V2TimConversation> _currentMessageList = []; //会话列表
  int _unreadCount = 0; //未读总数

  V2TimConversation? _v2timConversation; //单个会话信息

  List<V2TimMessage> _groupMsgList = []; //群聊消息

  List<V2TimMessage> get c2CMsgList => _c2CMsgList;
  List<V2TimConversation> get currentMessageList => _currentMessageList;
  int get unreadCount => _unreadCount;

  V2TimConversation? get v2timConversation => _v2timConversation;

  List<V2TimMessage> get groupMsgList => _groupMsgList;

  //聊天界面的用户 和谁在聊天 converID 时单聊 userId 也是 群聊ID
  setConverID(converID) {
    converId = converID;
  }

  //是否在聊天界面
  chatPage(ChaPage chaPage) {
    isChaPage = chaPage;
  }

  //接收 消息
  recvNewMessage(V2TimMessage newMessage) {
    // AudioCache player = AudioCache();
    // player.play('mp3/13203.wav');
    if (isChaPage == ChaPage.crc) {
      if (newMessage.userID == converId) {
        //消息去重
        if (newMessage.msgID != _c2CMsgList[0].msgID) {
          _c2CMsgList.insert(0, newMessage);
          eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));
          clearC2CMsgUnRead(converId);
        }
      }
    } else {
      if (newMessage.groupID == converId) {
        //消息去重
        if (newMessage.msgID != _groupMsgList[0].msgID) {
          _groupMsgList.insert(0, newMessage);
          eventBus.fire(UpdateGroupChatPageEvent(_groupMsgList));
          clearGroupMsgUnRead(converId);
        }
      }
    }
  }

  //创建 文本 消息
  createTextMsg(String msgtext, String converID, bool isGroup) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createTextMessage(text: msgtext);
    String id = createMessage.data!.id!; // 返回的消息创建id

    updateAndSend(id, converID, isGroup, createMessage.data!.messageInfo!);
  }

  //创建 表情 消息
  createFaceMsg(int index, String msg, String converID, bool isGroup) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createFaceMessage(index: index, data: msg);
    String id = createMessage.data!.id!; // 返回的消息创建id

    updateAndSend(id, converID, isGroup, createMessage.data!.messageInfo!);
  }

  //创建 图片 消息
  createImageMsg(String imagePath, String converID, bool isGroup) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createImageMessage(imagePath: imagePath);
    String id = createMessage.data!.id!; // 返回的消息创建id

    updateAndSend(id, converID, isGroup, createMessage.data!.messageInfo!);
  }

  //创建 视频 消息
  createVideoMsg(String videoFilePath, String type, int duration,
      String snapshotPath, String converID, bool isGroup) async {
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

    updateAndSend(id, converID, isGroup, createMessage.data!.messageInfo!);
  }

  //创建 语音 消息
  createSoundMsg(
      String soundPath, int duration, String converID, bool isGroup) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createSoundMessage(soundPath: soundPath, duration: duration);
    String id = createMessage.data!.id!; // 返回的消息创建id

    updateAndSend(id, converID, isGroup, createMessage.data!.messageInfo!);
  }

  /* 
    ##  创建自定义消息
    ## PROMPT- (不更新会话的提示类 自定义信息)
    ## CONCISE- (不更新会话的自我介绍 自定义信息)
    ## VOICECALL- (不更新未读数的语音通话 自定义信息)
    ## CGTP- (常见群聊成功 提示类 自定义信息)

  */
  createCustomMsg(
    String msgtext,
    String converID,
    bool isGroup, {
    bool isExcludedFromUnreadCount = false,
    bool isExcludedFromLastMessage = false,
  }) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createCustomMessage(data: msgtext);
    String id = createMessage.data!.id!; // 返回的消息创建id

    if (isGroup) {
      _groupMsgList.insert(0, createMessage.data!.messageInfo!);
      eventBus.fire(UpdateGroupChatPageEvent(_groupMsgList));

      sendGroupMessage(
        id,
        converID,
        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        isExcludedFromLastMessage: isExcludedFromLastMessage,
      );
    } else {
      _c2CMsgList.insert(0, createMessage.data!.messageInfo!);
      eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));

      sendMessage(
        id,
        converID,
        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        isExcludedFromLastMessage: isExcludedFromLastMessage,
      );
    }
  }

  //更新页面 发送消息
  updateAndSend(
      String id, String converID, bool isGroup, V2TimMessage messageInfo) {
    if (isGroup) {
      _groupMsgList.insert(0, messageInfo);
      eventBus.fire(UpdateGroupChatPageEvent(_groupMsgList));
      sendGroupMessage(id, converID);
    } else {
      _c2CMsgList.insert(0, messageInfo);
      eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));
      sendMessage(id, converID);
    }
  }

  //发送 单聊 消息
  sendMessage(
    String id,
    String userID, {
    bool isExcludedFromUnreadCount = false,
    bool isExcludedFromLastMessage = false,
  }) async {
    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id, // 将消息创建id传递给
              receiver: userID,
              groupID: "",
              isExcludedFromUnreadCount: isExcludedFromUnreadCount,
              isExcludedFromLastMessage: isExcludedFromLastMessage,
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

  //发送 群聊 消息
  sendGroupMessage(
    String id,
    String groupID, {
    bool isExcludedFromUnreadCount = false,
    bool isExcludedFromLastMessage = false,
  }) async {
    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id, // 将消息创建id传递给
              receiver: "",
              groupID: groupID,
              isExcludedFromUnreadCount: isExcludedFromUnreadCount,
              isExcludedFromLastMessage: isExcludedFromLastMessage,
            );
    if (res.data != null) {
      for (int i = 0; i < _groupMsgList.length; i++) {
        if (_groupMsgList[i].id == res.data!.id) {
          _groupMsgList[i] = res.data!;
          eventBus.fire(UpdateGroupChatPageEvent(_groupMsgList));
        }
      }
    }
  }

  //设置草稿箱
  setConversationDraft(conversationID, draftText) async {
    await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .setConversationDraft(
            conversationID: conversationID, draftText: draftText);
  }

  //设置本地消息 用来设置语音 红点未读
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
  getC2CMsgList(userID, showName, context) async {
    _c2CMsgList = [];
    V2TimValueCallback<List<V2TimMessage>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getMessageManager()
        .getC2CHistoryMessageList(
          userID: userID!,
          count: 20,
        );
    _c2CMsgList = res.data!;
    eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));

    if (res.code == 0) {
      _groupMsgList = res.data!;
      Application.router.navigateTo(
        context,
        "/chatDetail",
        transition: TransitionType.inFromRight,
        routeSettings: RouteSettings(
          arguments: {
            "userID": userID,
            "showName": showName,
          },
        ),
      );
    } else {
      ErrorTips.errorMsg(res.code);
    }
  }

  //获取群聊 最新的20条
  getGroupMsgList(V2TimConversation item, context) async {
    _groupMsgList = [];
    V2TimValueCallback<List<V2TimMessage>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getMessageManager()
        .getGroupHistoryMessageList(groupID: item.groupID!, count: 20);
    if (res.code == 0) {
      _groupMsgList = res.data!;

      Application.router.navigateTo(
        context,
        "/groupChatPage",
        transition: TransitionType.inFromRight,
        routeSettings: RouteSettings(
          arguments: {
            "groupID": item.groupID,
            "showName": item.showName,
          },
        ),
      );
    } else {
      ErrorTips.errorMsg(res.code);
    }
  }

  //获取 单聊 历史消息
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

  //获取 群聊 历史消息
  getGroupHistoryMsgList(groupID, List<V2TimMessage> msgList) async {
    if (msgList.isNotEmpty) {
      var lastMsgID = msgList[msgList.length - 1].msgID;

      V2TimValueCallback<List<V2TimMessage>> nextRes = await TencentImSDKPlugin
          .v2TIMManager
          .getMessageManager()
          .getGroupHistoryMessageList(
            groupID: groupID!,
            count: 20,
            lastMsgID: lastMsgID,
          );
      if (nextRes.data != null) {
        _groupMsgList.addAll(nextRes.data!);
      }
      eventBus.fire(UpdateGroupChatPageEvent(_groupMsgList));
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
    
    会话操作
  
   */
  //获取会话列表
  getConversationList() async {
    V2TimValueCallback<V2TimConversationResult> data = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversationList(count: 100, nextSeq: "0");

    if (data.data!.conversationList!.isNotEmpty) {
      _currentMessageList =
          data.data!.conversationList!.cast<V2TimConversation>();
      notifyListeners();
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

  //获取未读数总数 getTotalUnreadMessageCount 获取不到总未读数
  getUnreadTotalCount(count) async {
    _unreadCount = count;
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

  ///获取 指定 会话的信息 "c2c_$conversationID"
  getConversation(conversationID) async {
    V2TimValueCallback<V2TimConversation> res = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversation(conversationID: conversationID);
    if (res.data != null) {
      _v2timConversation = res.data;
      notifyListeners();
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

  // 清空群聊未读消息数
  clearGroupMsgUnRead(groupID) async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .markGroupMessageAsRead(groupID: groupID);
    if (res.code == 0) {
      getConversationList();
    }
  }
}

enum ChaPage {
  noPage,
  crc,
  group,
}
