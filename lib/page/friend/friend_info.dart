import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';

import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:my_chat/utils/constant.dart';
import 'package:my_chat/utils/event_bus.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

class FriendInfoPage extends StatefulWidget {
  String? userID;
  FriendInfoPage({
    Key? key,
    this.userID,
  }) : super(key: key);

  @override
  State<FriendInfoPage> createState() => _FriendInfoPageState();
}

class _FriendInfoPageState extends State<FriendInfoPage> {
  var showName = "";
  V2TimFriendInfoResult? _friendInfo;

  @override
  void initState() {
    super.initState();
    //修改备注 刷新
    eventBus.on<NoticeEvent>().listen((event) {
      if (mounted) {
        if (event.notice == Notice.remark) {
          getUserInfo();
        }
      }
    });
    getUserInfo();
  }

  //获取好友信息
  getUserInfo() async {
    _friendInfo = await Friend.getFriendsInfo(widget.userID);
    if (_friendInfo != null) {
      if (_friendInfo!.friendInfo!.friendRemark!.length == 0) {
        showName = _friendInfo!.friendInfo!.userProfile!.nickName!;
      } else {
        showName = _friendInfo!.friendInfo!.friendRemark!;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backBtn(context),
      ),
      body: Container(
        child: _friendInfo == null
            ? Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: 50.r,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "该用户不存在",
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 30.sp,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : Column(
                children: [
                  info(_friendInfo!),
                  SizedBox(height: 30.h),
                  Container(
                    child: _friendInfo!.relation == 0
                        ? additem()
                        : sendFriendMsg(),
                  )
                ],
              ),
      ),
    );
  }

  // 头部信息
  Widget info(V2TimFriendInfoResult info) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 40.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Avatar(
              isSelf: false,
              size: 120.r,
              faceUrl: info.friendInfo!.userProfile!.faceUrl!,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 10.r),
                  child: Text(
                    "${showName}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                info.friendInfo!.friendRemark!.length == 0
                    ? Container()
                    : Container(
                        padding: EdgeInsets.only(bottom: 5.r),
                        child: Text(
                          "昵称:${info.friendInfo!.userProfile!.nickName}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 28.sp,
                          ),
                        ),
                      ),
                Container(
                  padding: EdgeInsets.only(bottom: 5.r),
                  child: Text(
                    "ID:${info.friendInfo!.userProfile!.userID}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 28.sp,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 5.r),
                  child: Text(
                    "签名: 暂无设置签名",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 28.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 添加好友 打电话 的列表
  Widget additem() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Application.router.navigateTo(
                context,
                "/sendAddPage",
                transition: TransitionType.inFromRight,
                routeSettings: RouteSettings(
                  arguments: {
                    "userID": widget.userID,
                  },
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(20.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      "添加好友",
                      style: TextStyle(
                        fontSize: 30.sp,
                        color: Colors.blue,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // 给好友发送消息
  Widget sendFriendMsg() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Provider.of<Chat>(context, listen: false)
                  .getC2CMsgList(widget.userID, context);
            },
            child: Container(
              padding: EdgeInsets.all(20.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      "发送消息",
                      style: TextStyle(
                        fontSize: 30.sp,
                        color: Colors.blue,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
