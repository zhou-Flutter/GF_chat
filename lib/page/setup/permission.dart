import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/user_info_allow_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

class Permission extends StatefulWidget {
  const Permission({Key? key}) : super(key: key);

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  bool flag = false;
  List<V2TimUserFullInfo> selfInfo = [];

  V2TimUserFullInfo? info;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selfInfo = Provider.of<Chat>(context, listen: false).selfInfo;
    if (selfInfo.isNotEmpty) {
      info = selfInfo[0];
      print(info!.allowType);
      if (info!.allowType == AllowType.V2TIM_FRIEND_NEED_CONFIRM) {
        flag = true;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backBtn(context),
        title: Text("权限"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 25.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 10.r),
              color: Colors.white,
              child: Row(
                children: [
                  Text(
                    "加我为朋友时需要验证",
                    style: TextStyle(fontSize: 30.sp),
                  ),
                  const Spacer(),
                  Switch(
                    value: flag,
                    onChanged: (value) {
                      setState(() {
                        flag = value;
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
