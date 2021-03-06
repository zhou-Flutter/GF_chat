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
  ChaPage isChaPage = ChaPage.noPage; //???????????? ???????????? ???
  List<V2TimMessage> _c2CMsgList = []; //??????
  List<V2TimConversation> _currentMessageList = []; //????????????
  int _unreadCount = 0; //????????????

  V2TimConversation? _v2timConversation; //??????????????????

  List<V2TimMessage> _groupMsgList = []; //????????????

  List<V2TimMessage> get c2CMsgList => _c2CMsgList;
  List<V2TimConversation> get currentMessageList => _currentMessageList;
  int get unreadCount => _unreadCount;

  V2TimConversation? get v2timConversation => _v2timConversation;

  List<V2TimMessage> get groupMsgList => _groupMsgList;

  //????????????????????? ??????????????? converID ????????? userId ?????? ??????ID
  setConverID(converID) {
    converId = converID;
  }

  //?????????????????????
  chatPage(ChaPage chaPage) {
    isChaPage = chaPage;
  }

  //?????? ??????
  recvNewMessage(V2TimMessage newMessage) {
    // AudioCache player = AudioCache();
    // player.play('mp3/13203.wav');
    if (isChaPage == ChaPage.crc) {
      if (newMessage.userID == converId) {
        //????????????
        if (newMessage.msgID != _c2CMsgList[0].msgID) {
          _c2CMsgList.insert(0, newMessage);
          eventBus.fire(UpdateChatPageEvent(_c2CMsgList, false));
          clearC2CMsgUnRead(converId);
        }
      }
    } else {
      if (newMessage.groupID == converId) {
        //????????????
        if (newMessage.msgID != _groupMsgList[0].msgID) {
          _groupMsgList.insert(0, newMessage);
          eventBus.fire(UpdateGroupChatPageEvent(_groupMsgList));
          clearGroupMsgUnRead(converId);
        }
      }
    }
  }

  //?????? ?????? ??????
  createTextMsg(String msgtext, String converID, bool isGroup) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createTextMessage(text: msgtext);
    String id = createMessage.data!.id!; // ?????????????????????id

    updateAndSend(id, converID, isGroup, createMessage.data!.messageInfo!);
  }

  //?????? ?????? ??????
  createFaceMsg(int index, String msg, String converID, bool isGroup) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createFaceMessage(index: index, data: msg);
    String id = createMessage.data!.id!; // ?????????????????????id

    updateAndSend(id, converID, isGroup, createMessage.data!.messageInfo!);
  }

  //?????? ?????? ??????
  createImageMsg(String imagePath, String converID, bool isGroup) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createImageMessage(imagePath: imagePath);
    String id = createMessage.data!.id!; // ?????????????????????id

    updateAndSend(id, converID, isGroup, createMessage.data!.messageInfo!);
  }

  //?????? ?????? ??????
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
    String id = createMessage.data!.id!; // ?????????????????????id

    updateAndSend(id, converID, isGroup, createMessage.data!.messageInfo!);
  }

  //?????? ?????? ??????
  createSoundMsg(
      String soundPath, int duration, String converID, bool isGroup) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createSoundMessage(soundPath: soundPath, duration: duration);
    String id = createMessage.data!.id!; // ?????????????????????id

    updateAndSend(id, converID, isGroup, createMessage.data!.messageInfo!);
  }

  /* 
    ##  ?????????????????????
    ## PROMPT- (??????????????????????????? ???????????????)
    ## CONCISE- (?????????????????????????????? ???????????????)
    ## VOICECALL- (????????????????????????????????? ???????????????)
    ## CGTP- (?????????????????? ????????? ???????????????)

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
    String id = createMessage.data!.id!; // ?????????????????????id

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

  //???????????? ????????????
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

  //?????? ?????? ??????
  sendMessage(
    String id,
    String userID, {
    bool isExcludedFromUnreadCount = false,
    bool isExcludedFromLastMessage = false,
  }) async {
    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id, // ???????????????id?????????
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

  //?????? ?????? ??????
  sendGroupMessage(
    String id,
    String groupID, {
    bool isExcludedFromUnreadCount = false,
    bool isExcludedFromLastMessage = false,
  }) async {
    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id, // ???????????????id?????????
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

  //???????????????
  setConversationDraft(conversationID, draftText) async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .setConversationDraft(
            conversationID: conversationID, draftText: draftText);

    if (res.code == 0) {
    } else {
      ErrorTips.errorMsg(res.code);
    }
  }

  //?????????????????? ?????????????????? ????????????
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

  //?????????????????? ?????????20???
  getC2CMsgList(userID, context) async {
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
          },
        ),
      );
    } else {
      ErrorTips.errorMsg(res.code);
    }
  }

  //???????????? ?????????20???
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

  //?????? ?????? ????????????
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

  //?????? ?????? ????????????
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

  //??????????????????
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

  //????????????
  revokeMessage(msgID) async {
    await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .revokeMessage(msgID: msgID);
    revoke(msgID);
  }

  //?????? ?????? ????????????
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
    
    ????????????
  
   */
  //??????????????????
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

  //?????????????????????
  getUnreadCount() async {
    V2TimValueCallback<int> data = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .getTotalUnreadMessageCount();
    _unreadCount = data.data!.bitLength;
    notifyListeners();
  }

  //????????????????????? getTotalUnreadMessageCount ????????????????????????
  getUnreadTotalCount(count) async {
    _unreadCount = count;
    notifyListeners();
  }

  //????????????
  pinConversation(String conversationID, bool isPinned) async {
    await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .pinConversation(conversationID: conversationID, isPinned: isPinned);
  }

  //????????????
  deleteConversation(String conversationID) async {
    await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .deleteConversation(conversationID: conversationID);
    getConversationList();
  }

  ///?????? ?????? ??????????????? "c2c_$conversationID"
  static Future<V2TimConversation?> getConversationInfo(
      bool isGroup, converID) async {
    var conversationID = "";
    if (isGroup) {
      conversationID = "group_$converID";
    } else {
      conversationID = "c2c_$converID";
    }
    V2TimValueCallback<V2TimConversation> res = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversation(conversationID: conversationID);
    if (res.code == 0) {
      return res.data;
    }
  }

  // ???????????????????????????
  clearC2CMsgUnRead(userID) async {
    print(userID);
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .markC2CMessageAsRead(userID: userID);
    if (res.code == 0) {
      getConversationList();
    }
  }

  // ???????????????????????????
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
