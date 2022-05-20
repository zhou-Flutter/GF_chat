import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';

class BlackList extends StatefulWidget {
  BlackList({Key? key}) : super(key: key);

  @override
  State<BlackList> createState() => _BlackListState();
}

class _BlackListState extends State<BlackList> {
  List<V2TimFriendInfo> blackList = [];
  @override
  void initState() {
    super.initState();
    Provider.of<Chat>(context, listen: false).getBlackList();
  }

  @override
  Widget build(BuildContext context) {
    blackList = Provider.of<Chat>(context, listen: false).blackList;
    return Scaffold(
      appBar: AppBar(
        leading: backBtn(context),
        title: Text("黑名单"),
      ),
      body: SingleChildScrollView(
        child: blackList.length == 0
            ? Container(
                padding: EdgeInsets.all(100.r),
                child: Text("暂无黑名单"),
              )
            : Column(
                children: blackList.map((e) {
                  return blackListItem(e);
                }).toList(),
              ),
      ),
    );
  }

  Widget blackListItem(V2TimFriendInfo item) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.r, horizontal: 25.r),
            height: 75.r,
            width: 75.r,
            child: Avatar(
              isSelf: false,
              size: 75.r,
              faceUrl: item.userProfile!.faceUrl,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10.r),
            child: Text(
              "${item.userProfile!.nickName}",
              style: TextStyle(fontSize: 30.sp),
            ),
          )
        ],
      ),
    );
  }
}
