import 'package:fluro/fluro.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';

class AgreementDialog extends StatelessWidget {
  Function AgreeCallback;
  AgreementDialog({required this.AgreeCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          height: 0.45.sw,
          width: 0.8.sw,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "同意隐私条款",
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(25),
                child: RichText(
                  text: TextSpan(
                      text: "登录注册需要您阅读并同意我们的",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 25.sp,
                      ),
                      children: [
                        TextSpan(
                            text: "《用户协议》",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 25.sp,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Application.router.navigateTo(
                                  context,
                                  "/userAgreement",
                                  transition: TransitionType.inFromRight,
                                );
                              }),
                        TextSpan(
                          text: " 和 ",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 25.sp,
                          ),
                        ),
                        TextSpan(
                            text: "《隐私政策》",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 25.sp,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {}),
                      ]),
                ),
              ),
              Divider(height: 1, color: Colors.black54),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Application.router.pop(context);
                        },
                        child: Container(
                          height: 75.h,
                          alignment: Alignment.center,
                          child: Text(
                            "不同意",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 30.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 75.h,
                      child: const VerticalDivider(
                        width: 1,
                        color: Colors.black54,
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Application.router.pop(context);
                          AgreeCallback();
                        },
                        child: Container(
                          height: 75.h,
                          alignment: Alignment.center,
                          child: Text(
                            "我同意",
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 30.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
