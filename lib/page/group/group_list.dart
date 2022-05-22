import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';

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
    joinedGroupList = Provider.of<Chat>(context, listen: false).joinedGroupList;
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
      body: ListView.builder(
        itemCount: joinedGroupList.length,
        itemBuilder: (context, index) {
          return groupItem(joinedGroupList[index]);
        },
      ),
    );
  }

  Widget groupItem(V2TimGroupInfo item) {
    return CustomTap(
      tapColor: HexColor.fromHex('#f5f5f5'),
      onTap: () {
        Application.router.navigateTo(
          context,
          "/groupChatPage",
          transition: TransitionType.inFromRight,
          routeSettings: RouteSettings(
            arguments: {
              "groupID": item.groupID,
              "showName": item.groupName,
            },
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.r, horizontal: 25.r),
            child: Avatar(
              isSelf: false,
              size: 75.r,
              faceUrl: item.faceUrl,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10.r),
            child: Text(
              "${item.groupName}",
              style: TextStyle(fontSize: 30.sp),
            ),
          )
        ],
      ),
    );
  }
}
