import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/provider/init_provider.dart';
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
  V2TimUserFullInfo? selfInfo;
  var isshow = true;
  final List _list = [
    {
      "id": 1,
      "icon": 0xe632,
      "name": "收藏",
      "iconColor": HexColor.fromHex('#5CACEE')
    },
    {
      "id": 2,
      "icon": 0xe7f2,
      "name": "表情",
      "iconColor": HexColor.fromHex('#66CDAA'),
    },
    {
      "id": 3,
      "icon": 0xe606,
      "name": "实验室",
      "iconColor": HexColor.fromHex('#EE7942'),
    },
    {
      "id": 4,
      "icon": 0xe867,
      "name": "更多",
      "iconColor": HexColor.fromHex('#EEAD0E'),
    },
  ];

  @override
  void initState() {
    super.initState();
    selfInfo = Provider.of<Friend>(context, listen: false).selfInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          hander(),
          SizedBox(height: 30.h),
          toolItem(),
          SizedBox(height: 30.h),
          setUp(),
        ],
      ),
    );
  }

  // 头部信息
  Widget hander() {
    return InkWell(
      onTap: () {
        Application.router.navigateTo(
          context,
          "/selfInfoPage",
          transition: TransitionType.inFromRight,
        );
      },
      child: Container(
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
                  selfInfo!.faceUrl!,
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
                      "${selfInfo!.nickName}",
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
                      "ID:${selfInfo!.userID}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 28.sp,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 20.r, top: 10.r),
                    child: Row(
                      children: [
                        Container(
                          // width: 100.w,
                          height: 40.r,
                          padding: EdgeInsets.only(
                            right: 10.r,
                            left: 5.r,
                            top: 2.r,
                            bottom: 2.r,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12, width: 1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.black45,
                                size: 25.sp,
                              ),
                              SizedBox(width: 3.r),
                              Text(
                                "状态",
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20.r),
                        Container(
                          width: 37.r,
                          height: 37.r,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.black26, width: 1.r),
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Icon(
                            Icons.more_horiz,
                            size: 30.sp,
                            color: Colors.black45,
                          ),
                        )
                      ],
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
                ),
                Container(
                  padding: EdgeInsets.only(top: 80.r, left: 10),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.black54,
                  ),
                ),
              ],
            )
          ],
        ),
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
                    indent: 100.r,
                    color: Colors.black12,
                  ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 35.r),
              child: Row(
                children: [
                  Container(
                    height: 60.r,
                    width: 60.r,
                    margin:
                        EdgeInsets.only(top: 15.r, bottom: 15.r, right: 10.r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      color: e["iconColor"],
                    ),
                    child: Icon(
                      IconData(e["icon"], fontFamily: "icons"),
                      size: 35.r,
                      color: Colors.white,
                    ),
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
          "/setUpPage",
          transition: TransitionType.inFromRight,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 35.r),
        child: Row(
          children: [
            Container(
              height: 60.r,
              width: 60.r,
              margin: EdgeInsets.only(top: 15.r, bottom: 15.r, right: 10.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                color: HexColor.fromHex('#87CEFA'),
              ),
              child: Icon(
                IconData(0xe699, fontFamily: "icons"),
                size: 45.r,
                color: Colors.white,
              ),
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
