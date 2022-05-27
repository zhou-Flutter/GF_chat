import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';

class LoginMobileBtn extends StatelessWidget {
  const LoginMobileBtn({Key? key}) : super(key: key);
// 未获取到手机号  点击跳转 手机号登录
  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          Application.router.navigateTo(
            context,
            "/mobileNumLoginPage",
            transition: TransitionType.inFromRight,
          );
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(15),
          width: 600.w,
          decoration: BoxDecoration(
            color: Colors.white38,
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Text(
            "手机号登录",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
