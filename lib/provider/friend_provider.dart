import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/model/tencent_api_resp.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/login_provider.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:my_chat/utils/constant.dart';
import 'package:my_chat/utils/error_tips.dart';
import 'package:my_chat/utils/event_bus.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_response_type_enum.dart';
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
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class Friend with ChangeNotifier {
  var groupId; // 群聊ID
  bool ischatPage = false;
  List<V2TimFriendInfo> _friendList = []; //好友列表
  List<V2TimUserFullInfo> _usersInfo = []; //用户信息
  V2TimUserFullInfo? _selfInfo; //自己的信息
  V2TimFriendInfoResult? _friendInfo; //指定好友的信息
  List<V2TimFriendInfo> _blackList = []; //黑名单
  int _friendApplicationUnreadCount = 0; //申请好友未读数
  List<V2TimFriendApplication?>? _applicationList = []; //申请列表
  List<V2TimFriendInfoResult>? _searchFriend = []; //搜索好友列表
  List<V2TimGroupInfo> _joinedGroupList = []; //加入群组的
  List<V2TimConversation> _currentMessageList = []; //会话列表

  List<V2TimGroupMemberFullInfo?> _groupMemberList = []; //群成员
  List<V2TimGroupMemberFullInfo?> get groupMemberList => _groupMemberList;
  List<V2TimFriendInfo> get friendList => _friendList;
  List<V2TimUserFullInfo> get usersInfo => _usersInfo;
  V2TimUserFullInfo? get selfInfo => _selfInfo;
  V2TimFriendInfoResult? get friendInfo => _friendInfo;
  List<V2TimFriendInfo> get blackList => _blackList;
  int get friendApplicationUnreadCount => _friendApplicationUnreadCount;
  List<V2TimFriendApplication?>? get applicationList => _applicationList;
  List<V2TimFriendInfoResult>? get searchFriend => _searchFriend;
  List<V2TimGroupInfo> get joinedGroupList => _joinedGroupList;
  List<V2TimConversation> get currentMessageList => _currentMessageList;

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
  static Future<V2TimFriendInfoResult?> getFriendsInfo(userIDList) async {
    V2TimValueCallback<List<V2TimFriendInfoResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendsInfo(userIDList: [userIDList]);
    print(res.data!.length);
    if (res.code == 0) {
      return res.data![0];
    } else {
      print("查询失败");
    }
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
      Provider.of<Chat>(context, listen: false)
          .deleteConversation("c2c_$userID");
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
  getSelfInfo() async {
    V2TimValueCallback<List<V2TimUserFullInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getUsersInfo(userIDList: [Constant.userId]);
    if (res.code == 0) {
      _selfInfo = res.data![0];
      notifyListeners();
    } else {}
  }

  //获取黑名单
  static Future<List<V2TimFriendInfo>?> getBlackList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getFriendshipManager()
        .getBlackList();
    if (res.code == 0) {
      return res.data!;
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
      Provider.of<Chat>(context, listen: false)
          .createTextMsg("我通过了你的请求", userID, false);
      //发送不更新会话的消息
      Provider.of<Chat>(context, listen: false).createCustomMsg(
        "PROMPT-你们已经是好友了",
        userID,
        false,
        isExcludedFromUnreadCount: true,
        isExcludedFromLastMessage: true,
      );
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
  setFriendInfo(userID, friendRemark, context) async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .setFriendInfo(userID: userID, friendRemark: friendRemark);
    if (res.code == 0) {
      getFriendList();
      Provider.of<Chat>(context, listen: false).getConversationList();
      eventBus.fire(NoticeEvent(Notice.remark));
      Application.router.pop(context);
    }
  }

  //搜索好友
  searchFriends(V2TimFriendSearchParam searchParam) async {
    V2TimValueCallback<List<V2TimFriendInfoResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .searchFriends(searchParam: searchParam);
    if (res.code == 0) {
      _searchFriend = res.data;
      notifyListeners();
    } else {
      ErrorTips.errorMsg(res.code);
    }
  }

  //创建群聊
  createGroup(List<V2TimFriendInfo> memberList, context) async {
    List<V2TimGroupMember> list = [];

    for (V2TimFriendInfo item in memberList) {
      list.add(V2TimGroupMember(
          userID: item.userID,
          role: GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_MEMBER));
    }
    V2TimValueCallback<String> res =
        await TencentImSDKPlugin.v2TIMManager.getGroupManager().createGroup(
              groupType: "Work", // 工作群
              groupName: "群聊",
              notification: "工作群", // 群通告
              introduction: "工作群", // 群介绍
              isAllMuted: false, // 是否全员禁言
              faceUrl: "...",
              addOpt: GroupAddOptTypeEnum.V2TIM_GROUP_ADD_ANY, // 加群权限
              memberList: list, // 创建时加入的成员
            );

    if (res.code == 0) {
      Fluttertoast.showToast(msg: "创建成功");

      //发送 不计入未读  消息
      Provider.of<Chat>(context, listen: false).createCustomMsg(
        "PROMPT-创建群聊成功",
        res.data!,
        true,
        isExcludedFromUnreadCount: true,
        isExcludedFromLastMessage: false,
      );

      Application.router.navigateTo(
        context,
        "/bottomNav",
        clearStack: true,
        transition: TransitionType.inFromRight,
      );
    } else {
      Fluttertoast.showToast(msg: "创建失败");
    }
  }

  //获取加入的群聊
  static Future<List<V2TimGroupInfo>?> getJoinedGroupList() async {
    V2TimValueCallback<List<V2TimGroupInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getGroupManager()
        .getJoinedGroupList();
    if (res.code == 0) {
      return res.data!;
    } else {
      print('获取失败');
    }
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

  ///获取群资料
  static Future<V2TimGroupInfoResult?> getGroupsInfo(groupIDList) async {
    V2TimValueCallback<List<V2TimGroupInfoResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupsInfo(groupIDList: [groupIDList]);

    if (res.code == 0) {
      return res.data![0];
    } else {
      ErrorTips.errorMsg(res.code);
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
      print("推出失败");
    }
  }
}
