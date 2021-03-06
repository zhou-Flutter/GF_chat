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
import 'package:my_chat/provider/friend_provider.dart';
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
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_kit/tencent_kit.dart';

class InitProvider with ChangeNotifier {
  //?????????IM SDK
  initSDK(context) async {
    V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;
    await timManager.initSDK(
        sdkAppID: 1400559934,
        loglevel: LogLevelEnum.V2TIM_LOG_ERROR,
        listener: V2TimSDKListener(
          onConnecting: () {
            print("????????????");
          },
          onConnectFailed: (code, error) {
            print("???????????????????????????");
          },
          onConnectSuccess: () {
            print("????????????");
          },
          onKickedOffline: () {
            print("?????????");
          },
          onSelfInfoUpdated: (info) {
            //??????????????????????????????????????????
            // Provider.of<Chat>(context, listen: false).getSelfInfo(_userId);
          },
          onUserSigExpired: () {},
        ));

    //??????????????????
    await timManager.getConversationManager().setConversationListener(
            listener: V2TimConversationListener(
          onConversationChanged: (List<V2TimConversation>? e) {
            print("??????????????????");
            Provider.of<Chat>(context, listen: false).getConversationList();
          },
          onNewConversation: (e) {
            print("???????????????");
            Provider.of<Chat>(context, listen: false).getConversationList();
          },
          onSyncServerFailed: () {},
          onSyncServerFinish: () {},
          onSyncServerStart: () {},
          onTotalUnreadMessageCountChanged: (e) {
            Provider.of<Chat>(context, listen: false).getUnreadTotalCount(e);
          },
        ));

    //??????????????????
    await timManager.getMessageManager().addAdvancedMsgListener(
          listener: V2TimAdvancedMsgListener(
            onRecvNewMessage: (v2TimMessage) {
              //????????????
              Provider.of<Chat>(context, listen: false)
                  .recvNewMessage(v2TimMessage);
            },
            onRecvMessageRevoked: (msgID) {
              //????????????
              Provider.of<Chat>(context, listen: false).revoke(msgID);
            },
          ),
        );

    //???????????????????????????
    await TencentImSDKPlugin.v2TIMManager.addGroupListener(
      listener: V2TimGroupListener(),
    );

    //???????????????????????????
    await timManager.getSignalingManager().addSignalingListener(
          listener: V2TimSignalingListener(
            onReceiveNewInvitation: (inviteID, inviter, c, d, data) {
              print("????????????");
              Provider.of<Trtc>(context, listen: false)
                  .receiveNewInvita(inviteID, data);
            },
            onInviteeAccepted: (a, b, e) {
              Provider.of<Trtc>(context, listen: false).acceptInviteBack();
            },
            onInviteeRejected: (a, b, c) {
              print("??????");
              Provider.of<Trtc>(context, listen: false).rejectInviteBack();
            },
            onInvitationCancelled: (a, b, c) {
              print("??????");
              Provider.of<Trtc>(context, listen: false).onInvitationCancelled();
            },
            onInvitationTimeout: (a, b) {
              print("??????");
            },
          ),
        );

    //????????????????????????
    await timManager.getFriendshipManager().setFriendListener(
          listener: V2TimFriendshipListener(
            onFriendListAdded: (List<V2TimFriendInfo> e) {
              Provider.of<Friend>(context, listen: false).getFriendList();

              Provider.of<Friend>(context, listen: false)
                  .getFriendApplicationList();
            },
            onFriendApplicationListAdded: (List<V2TimFriendApplication> e) {
              Provider.of<Friend>(context, listen: false)
                  .getFriendApplicationList();
            },
            onFriendApplicationListDeleted: (e) {
              print("??????????????????");
              Provider.of<Friend>(context, listen: false)
                  .getFriendApplicationList();
            },
          ),
        );
    //????????????
    await timManager.setGroupListener(
      listener: V2TimGroupListener(
        onMemberLeave: (groupID, member) {
          print("?????????????????????");
        },
      ),
    );
  }
}
