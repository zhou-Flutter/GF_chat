import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/utils/error_tips.dart';
import 'package:my_chat/utils/event_bus.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GroupChat with ChangeNotifier {
  var groupId; // 群聊ID
  bool ischatPage = false;

  List<V2TimGroupMemberFullInfo?> _groupMemberList = []; //群成员

  List<V2TimGroupMemberFullInfo?> get groupMemberList => _groupMemberList;

  // 清空单聊未读消息数
  clearGroupMsgUnRead(groupID) async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .markGroupMessageAsRead(groupID: groupID);
  }

  //获取所有群成员
  getGroupMemberList(groupID, context) async {
    V2TimValueCallback<V2TimGroupMemberInfoResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupMemberList(
                groupID: groupID,
                filter: GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL,
                nextSeq: "0");

    if (res.code == 0) {
      _groupMemberList = res.data!.memberInfoList!;
      Application.router.navigateTo(
        context,
        "/groupChatSetting",
        transition: TransitionType.inFromRight,
        routeSettings: RouteSettings(
          arguments: {
            "groupID": groupID,
          },
        ),
      );
    } else {
      print(res.code);
    }
  }

  //推出群聊
  quitGroup(groupID, context) async {
    V2TimCallback res =
        await TencentImSDKPlugin.v2TIMManager.quitGroup(groupID: groupID);
    if (res.code == 0) {
      Application.router.navigateTo(
        context,
        "/bottomNav",
        clearStack: true,
        transition: TransitionType.inFromRight,
      );
    } else {
      print("推出十八");
    }
  }
}
