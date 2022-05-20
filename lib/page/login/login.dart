import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/model/tencent_api_resp.dart';
import 'package:my_chat/page/login/component/login_agreement_dialog.dart';
import 'package:my_chat/provider/init_im_sdk_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/constant.dart';
import 'package:my_chat/utils/tencent.dart';
import 'package:provider/provider.dart';
import 'package:tencent_kit/tencent_kit.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  bool isSelect = false; //是否选择同意协议

  final String _TENCENT_APPID = '102005320';

  StreamSubscription<BaseResp>? _respSubs;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _respSubs = Tencent.instance.respStream().listen((BaseResp resp) {
      Provider.of<InitIMSDKProvider>(context, listen: false)
          .listenLogin(resp, context);
    });
  }

  // 未同意协议 同意后登录
  _login(loginType) {
    return showDialog(
      barrierDismissible: false, // 屏蔽点击对话框外部自动关闭
      context: context,
      builder: (context) {
        return AgreementDialog(AgreeCallback: () {
          isSelect = true;
          setState(() {});
          switch (loginType) {
            case LoginType.wx:
              //微信登录
              Fluttertoast.showToast(msg: "该版本无法使用微信登录");
              break;
            case LoginType.qq:
              //qq登录
              Provider.of<InitIMSDKProvider>(context, listen: false).qqLogin();
              break;
            case LoginType.iphone:
              //手机号码登录
              Application.router.navigateTo(
                context,
                "/mobileNumLoginPage",
                transition: TransitionType.inFromRight,
              );
              break;
            default:
          }
        });
      },
    );
  }

  // 同意协议 直接登录
  _directLogin(loginType) {
    switch (loginType) {
      case LoginType.wx:
        //微信登录
        Fluttertoast.showToast(msg: "该版本无法使用微信登录");
        break;
      case LoginType.qq:
        //qq登录
        Provider.of<InitIMSDKProvider>(context, listen: false).qqLogin();
        break;
      case LoginType.iphone:
        //手机号码登录
        Application.router.navigateTo(
          context,
          "/mobileNumLoginPage",
          transition: TransitionType.inFromRight,
        );
        break;
      default:
    }
  }

  @override
  void dispose() {
    _respSubs!.cancel();
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          children: [
            Container(
              child: bgAnimation(context, _animationController),
            ),
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                color: Colors.black54,
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          const SizedBox(height: 100),
                          Container(
                            width: 200.r,
                            height: 200.r,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10), //弧度
                              child: Image.asset(
                                Constant.assetsImg + "logo.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "遇见最好的朋友",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 35.sp,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Spacer(),
                    MobileNumLogin(),
                    otherLogin(),
                    Agreement(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget MobileNumLogin() {
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

  //快捷一键登录
  Widget QuickLogin() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              "177*****6262",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 40.sp,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              "中国电信提供认证服务",
              style: TextStyle(
                color: Colors.white38,
                fontWeight: FontWeight.w500,
                fontSize: 18.sp,
              ),
            ),
          ),
          Container(
            child: InkWell(
              onTap: () {
                // _setDateToPage(context);
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(15),
                width: 600.w,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(50),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.purple,
                      HexColor.fromHex('#9146E1'),
                    ],
                  ),
                ),
                child: Text(
                  "一键登录",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget otherLogin() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Column(
              children: [
                SizedBox(height: 50.r),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "其他方式登录",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.sp,
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          isSelect == true
                              ? _directLogin(LoginType.wx)
                              : _login(LoginType.wx);
                        },
                        child: Container(
                          padding: EdgeInsets.all(20.r),
                          width: 115.w,
                          height: 115.h,
                          child:
                              Image.asset(Constant.assetsImg + "login_wx.png"),
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          //qq
                          isSelect == true
                              ? _directLogin(LoginType.qq)
                              : _login(LoginType.qq);
                        },
                        child: Container(
                          padding: EdgeInsets.all(20.r),
                          width: 115.w,
                          height: 115.h,
                          child:
                              Image.asset(Constant.assetsImg + "login_qq.png"),
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          //手机登录
                          isSelect == true
                              ? _directLogin(LoginType.iphone)
                              : _login(LoginType.iphone);
                        },
                        child: Container(
                          padding: EdgeInsets.all(20.r),
                          width: 115.w,
                          height: 115.h,
                          child:
                              Image.asset(Constant.assetsImg + "login_ph.png"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  //协议
  Widget Agreement() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                isSelect = !isSelect;
                setState(() {});
              },
              child: isSelect == false
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

  //背景动画
  Widget bgAnimation(context, _animationController) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SlideTransition(
          position:
              Tween(begin: const Offset(0, -0.1), end: const Offset(0, -0.4))
                  .chain(CurveTween(curve: Curves.easeInOutCubic))
                  .animate(_animationController!),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 1500,
            color: Colors.black,
            child: Image.asset(
              Constant.assetsImg + "login03.jpg",
              fit: BoxFit.fill,
            ),
          ),
        ),
      ],
    );
  }
}

// 登录类型
enum LoginType {
  qq,
  wx,
  iphone,
}
