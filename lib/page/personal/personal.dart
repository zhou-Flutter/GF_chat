import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/init_im_sdk_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

class Personal extends StatefulWidget {
  Personal({Key? key}) : super(key: key);

  @override
  State<Personal> createState() => _PersonalState();
}

class _PersonalState extends State<Personal> {
  List<V2TimUserFullInfo> selfInfo = [];
  var isshow = true;
  final List _list = [
    {"id": 1, "icon": 0xe632, "name": "收藏", "iconColor": Colors.green},
    {"id": 2, "icon": 0xe7f2, "name": "表情", "iconColor": Colors.pink},
    {"id": 3, "icon": 0xe606, "name": "实验室", "iconColor": Colors.blue},
    {"id": 4, "icon": 0xe867, "name": "更多", "iconColor": Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    selfInfo = Provider.of<Chat>(context, listen: false).selfInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          selfInfo.isEmpty ? Container() : hander(selfInfo[0]),
          SizedBox(height: 30.h),
          toolItem(),
          SizedBox(height: 30.h),
          setUp(),
        ],
      ),
    );
  }

  // 头部信息
  Widget hander(V2TimUserFullInfo info) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 40.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120.r,
            height: 120.r,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10), //弧度
              child: Image.network(
                info.faceUrl!,
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 20.r),
                  child: Text(
                    "${info.nickName}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10.r),
                  child: Text(
                    "ID:${info.userID}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 28.sp,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 20.r),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(top: 80.r, left: 20),
                child: Icon(
                  IconData(0xe601, fontFamily: "icons"),
                  size: 30.r,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget toolItem() {
    return Column(
        children: _list.map((e) {
      return CustomTap(
        tapColor: HexColor.fromHex('#f5f5f5'),
        onTap: () {},
        child: Column(
          children: [
            e["id"] == 1
                ? Container()
                : Divider(
                    height: 1.r,
                    indent: 80.r,
                    color: Colors.black12,
                  ),
            Container(
              padding: EdgeInsets.all(25.r),
              child: Row(
                children: [
                  Icon(
                    IconData(e["icon"], fontFamily: "icons"),
                    size: 45.r,
                    color: e["iconColor"],
                  ),
                  SizedBox(width: 15.r),
                  Text(
                    "${e["name"]}",
                    style: TextStyle(
                      fontSize: 30.sp,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList());
  }

  Widget setUp() {
    return CustomTap(
      tapColor: HexColor.fromHex('#f5f5f5'),
      onTap: () {
        Application.router.navigateTo(
          context,
          "/addFriendPage",
          transition: TransitionType.inFromRight,
        );
      },
      child: Container(
        padding: EdgeInsets.all(20.r),
        child: Row(
          children: [
            Icon(
              IconData(0xe699, fontFamily: "icons"),
              size: 45.r,
              color: Colors.blue,
            ),
            SizedBox(width: 15.r),
            Text(
              "设置",
              style: TextStyle(
                fontSize: 30.sp,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
