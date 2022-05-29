import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/page/widget/common_dialog.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';

class GroupChatSetting extends StatefulWidget {
  String groupID;
  GroupChatSetting({
    Key? key,
    required this.groupID,
  }) : super(key: key);

  @override
  State<GroupChatSetting> createState() => _GroupChatSettingState();
}

class _GroupChatSettingState extends State<GroupChatSetting> {
  List<V2TimGroupMemberFullInfo?> groupMemberList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    groupMemberList =
        Provider.of<Friend>(context, listen: false).groupMemberList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backBtn(context),
        title: Text("群聊设置"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            groupMember(),
            Container(height: 25.h),
            groupInfo(),
            Container(height: 25.h),
            CustomTap(
              onTap: () {
                deleteDialog();
              },
              tapColor: HexColor.fromHex('#f5f5f5'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 20.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "删除并推出",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                        fontSize: 30.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //群成员
  Widget groupMember() {
    return Container(
      // height: 200.h,
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 20.r),
      color: Colors.white,
      child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
          ),
          itemCount: groupMemberList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == groupMemberList.length) {
              return addMember();
            } else {
              return memberAvatar(groupMemberList[index]!);
            }
          }),
    );
  }

  //成员头像
  Widget memberAvatar(V2TimGroupMemberFullInfo item) {
    return Container(
      child: Column(
        children: [
          Avatar(
            isSelf: false,
            size: 95.r,
            faceUrl: item.faceUrl,
          ),
          SizedBox(height: 5.h),
          Text(
            item.nickName!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black26,
              fontSize: 25.sp,
            ),
          ),
        ],
      ),
    );
  }

  //添加成员
  Widget addMember() {
    return InkWell(
      onTap: () {
        print("添加成员");
      },
      child: Column(
        children: [
          Container(
            width: 95.r,
            height: 95.r,
            decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: Colors.black26,
                  width: 1,
                )),
            child: Icon(
              Icons.add,
              size: 30.r,
            ),
          ),
        ],
      ),
    );
  }

  Widget groupInfo() {
    return CustomTap(
      onTap: () {},
      tapColor: HexColor.fromHex('#f5f5f5'),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 20.r),
        child: Row(
          children: [
            Text(
              "群聊名称",
              style: TextStyle(
                fontSize: 30.sp,
              ),
            ),
            const Spacer(),
            Text(
              "群聊名称",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 30.sp,
                color: Colors.black26,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  //删除群聊弹窗
  deleteDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return CommonDialog(
          title: "删除群聊",
          subtitle: "删除并推出后，将不再接受此群聊的信息",
          sure: "确定",
          clickCallback: () {
            Provider.of<Friend>(context, listen: false)
                .quitGroup(widget.groupID, context);
          },
        );
      },
    );
  }
}
