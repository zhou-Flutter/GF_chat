import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/page/home/component/group_avatar.dart';
import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GroupList extends StatefulWidget {
  const GroupList({Key? key}) : super(key: key);

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  List<V2TimGroupInfo> joinedGroupList = [];
  @override
  void initState() {
    super.initState();
    joinedGroupList =
        Provider.of<Friend>(context, listen: false).joinedGroupList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backBtn(context),
        title: Text(
          "群聊",
          style: TextStyle(fontSize: 30.sp),
        ),
      ),
      body: joinedGroupList.isEmpty
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: 200.h,
              color: Colors.white,
              child: Center(
                child: Text(
                  "暂无群聊",
                  style: TextStyle(
                    fontSize: 32.sp,
                    color: Colors.black45,
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: joinedGroupList.length,
              itemBuilder: (context, index) {
                return groupItem(
                  item: joinedGroupList[index],
                );
              },
            ),
    );
  }
}

class groupItem extends StatefulWidget {
  V2TimGroupInfo item;
  groupItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<groupItem> createState() => _groupItemState();
}

class _groupItemState extends State<groupItem> {
  List<V2TimGroupMemberFullInfo?> _groupMemberList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTap(
      tapColor: HexColor.fromHex('#f5f5f5'),
      onTap: () {
        Application.router.navigateTo(
          context,
          "/groupChatPage",
          transition: TransitionType.inFromRight,
          routeSettings: RouteSettings(
            arguments: {
              "groupID": widget.item.groupID,
              "showName": widget.item.groupName,
            },
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.r, horizontal: 25.r),
            child: GroupAvatar(
              size: 75.r,
              groupMemberList: _groupMemberList,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10.r),
            child: Text(
              widget.item.groupName!,
              style: TextStyle(fontSize: 30.sp),
            ),
          )
        ],
      ),
    );
  }
}
