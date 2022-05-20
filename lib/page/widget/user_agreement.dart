import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/utils/constant.dart';

class UserAgreement extends StatelessWidget {
  UserAgreement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            Constant.assetsImg + 'back_blc.png',
            width: 40.w,
          ),
          onPressed: () {
            Application.router.pop(context);
          },
        ),
        // brightness: Brightness.light,
        centerTitle: true,
        title: Text("用户协议"),
      ),
      body: Container(
        child: Text("用户协议"),
      ),
    );
  }
}
