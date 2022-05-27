import 'package:fluro/fluro.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/utils/constant.dart';

class LoginBottomAgreement extends StatelessWidget {
  bool isSelect;
  Function select;
  LoginBottomAgreement({
    required this.isSelect,
    required this.select,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                bool isSelect = !this.isSelect;
                this.select(isSelect);
              },
              child: this.isSelect == false
                  ? Container(
                      height: 25.r,
                      width: 25.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    )
                  : Container(
                      height: 25.r,
                      width: 25.r,
                      child: Image.asset(
                        Constant.assetsImg + "login_sbg.png",
                        fit: BoxFit.fill,
                      ),
                    ),
            ),
          ),
          Container(
            child: RichText(
              text: TextSpan(
                text: "我已阅读并同意",
                style: TextStyle(
                  color: Colors.white,
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
                      color: Colors.white,
                      fontSize: 25.sp,
                    ),
                  ),
                  TextSpan(
                      text: "《隐私协议》",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 25.sp,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
