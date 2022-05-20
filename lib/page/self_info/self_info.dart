import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';

import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

class SelfInfoPage extends StatefulWidget {
  SelfInfoPage({Key? key}) : super(key: key);

  @override
  State<SelfInfoPage> createState() => _SelfInfoPageState();
}

class _SelfInfoPageState extends State<SelfInfoPage> {
  List<V2TimUserFullInfo> selfInfo = [];
  V2TimUserFullInfo? info;

  @override
  void initState() {
    super.initState();
    selfInfo = Provider.of<Chat>(context, listen: false).selfInfo;
    if (selfInfo.isNotEmpty) {
      info = selfInfo[0];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backBtn(context),
        centerTitle: true,
        title: Text(
          "个人信息",
          style: TextStyle(fontSize: 35.sp),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            CustomTap(
              tapColor: HexColor.fromHex('#f5f5f5'),
              onTap: () {
                print("更换头像");
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(30.r),
                    child: Row(
                      children: [
                        Container(
                          child: Text(
                            "头像",
                            style: TextStyle(
                              fontSize: 30.sp,
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            print("查看头像");
                          },
                          child: Avatar(isSelf: true, size: 80.r),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.r,
                    indent: 30.r,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            CustomTap(
              tapColor: HexColor.fromHex('#f5f5f5'),
              onTap: () {
                print("更换头像");
              },
              child: Container(
                padding: EdgeInsets.all(30.r),
                child: Row(
                  children: [
                    Container(
                      child: Text("名称"),
                    ),
                    const Spacer(),
                    Text(
                      "${info!.nickName}",
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 30.sp,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
            CustomTap(
              tapColor: HexColor.fromHex('#f5f5f5'),
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(30.r),
                child: Row(
                  children: [
                    Container(
                      child: Text("GF号"),
                    ),
                    const Spacer(),
                    Text(
                      "${info!.userID}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 30.sp,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
            CustomTap(
              tapColor: HexColor.fromHex('#f5f5f5'),
              onTap: () {
                Application.router.navigateTo(
                  context,
                  "/selfQr",
                  transition: TransitionType.inFromRight,
                );
              },
              child: Container(
                padding: EdgeInsets.all(30.r),
                child: Row(
                  children: [
                    Container(
                      child: Text("二维码名片"),
                    ),
                    const Spacer(),
                    Icon(
                      IconData(0xe601, fontFamily: "icons"),
                      size: 30.sp,
                      color: Colors.black45,
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.black26,
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
}
