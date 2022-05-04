import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgreementDialog extends StatefulWidget {
  AgreementDialog({Key? key}) : super(key: key);

  @override
  State<AgreementDialog> createState() => _AgreementDialogState();
}

class _AgreementDialogState extends State<AgreementDialog> {
  List agreement = [
    "请您充分阅读并理解请您充分阅读并理解请您充分阅读并理解请您充分阅读并理解请您充分阅读并理解",
    "1,请您充分阅读并理解请您充分阅读并理解请您充分阅读并理解请您充分阅读并理解请您充分阅读并理解",
    "2,请您充分阅读并理解请您充分阅读并理解请您充分阅读并理解请您充分阅读并理解请您充分阅读并理解",
    "3,请您充分阅读并理解请您充分阅读并理解请您充分阅读并理解请您充分阅读并理解请您充分阅读并理解",
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          height: 0.83.sw,
          width: 0.8.sw,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "欢迎使用肝聊",
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 500.w,
                height: 250.h,
                child: ScrollConfiguration(
                  behavior: CusBehavior(), // 自定义的 behavior
                  child: ListView(
                    children: [
                      Container(
                        child: RichText(
                          text: TextSpan(
                              text: "请您充分阅读并理解",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25.sp,
                              ),
                              children: [
                                TextSpan(
                                    text: "《用户协议》",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 25.sp,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Application.router.navigateTo(
                                          context,
                                          "/userAgreement",
                                          transition:
                                              TransitionType.inFromRight,
                                        );
                                      }),
                                TextSpan(
                                  text: " 和 ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25.sp,
                                  ),
                                ),
                                TextSpan(
                                    text: "《隐私政策》",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 25.sp,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {}),
                              ]),
                        ),
                      ),
                      Column(
                        children: agreement.map<Widget>((e) {
                          return Container(
                            child: Text(
                              e,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25.sp,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: InkWell(
                  onTap: () {
                    SystemNavigator.pop();
                  },
                  child: Text(
                    "不同意并退出APP",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 25.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              InkWell(
                onTap: () {
                  _setDateToPage(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  width: 500.w,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.pink.shade200,
                        Colors.red,
                      ],
                    ),
                  ),
                  child: Text(
                    "同意",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _setDateToPage(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("isShow", 1);
    //跳转登陆页面
    Application.router.navigateTo(
      context,
      "/loginPage",
      clearStack: true,
      transition: TransitionType.inFromRight,
    );
  }
}

class CusBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    if (Platform.isAndroid || Platform.isFuchsia) return child;
    return super.buildViewportChrome(context, child, axisDirection);
  }
}
