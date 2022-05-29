import 'dart:async';
import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jverify/jverify.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/http/jv_request.dart';
import 'package:my_chat/model/tencent_api_resp.dart';
import 'package:my_chat/page/login/component/login_agreement_dialog.dart';
import 'package:my_chat/page/login/component/login_bg.dart';
import 'package:my_chat/page/login/component/login_bottom_agreement.dart';
import 'package:my_chat/page/login/component/login_head.dart';
import 'package:my_chat/page/login/component/login_mobile_btn.dart';
import 'package:my_chat/provider/init_provider.dart';
import 'package:my_chat/provider/login_provider.dart';
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

class _LoginPageState extends State<LoginPage> {
  //是否选择同意协议
  bool isSelect = false;

  //qq登录监听
  StreamSubscription<BaseResp>? _respSubs;

  //初始化极光插件
  final Jverify jverify = new Jverify();

  @override
  void initState() {
    super.initState();

    //qq登录监听
    _respSubs = Tencent.instance.respStream().listen((BaseResp resp) {
      Provider.of<Login>(context, listen: false).listenLogin(resp, context);
    });

    //开始极光认证 获取手机号码
    Provider.of<Login>(context, listen: false).initPlatformState();
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
          _directLogin(loginType);
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
        Provider.of<Login>(context, listen: false).qqLogin();
        break;
      case LoginType.iphone:
        //手机号码登录
        Application.router.navigateTo(
          context,
          "/mobileNumLoginPage",
          transition: TransitionType.inFromRight,
        );
        break;
      case LoginType.qukLogin:
        //手机号码登录
        Fluttertoast.showToast(msg: "一键登录手机号");
        break;
      default:
    }
  }

  @override
  void dispose() {
    _respSubs!.cancel();
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
            LoginBg(),
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                color: Colors.black54,
                child: Column(
                  children: [
                    LoginHead(),
                    Spacer(),
                    LoginMobileBtn(),
                    otherLogin(),
                    LoginBottomAgreement(
                      isSelect: isSelect,
                      select: (bool e) {
                        isSelect = e;
                        setState(() {});
                      },
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
                isSelect == true
                    ? _directLogin(LoginType.qukLogin)
                    : _login(LoginType.qukLogin);
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
}

// 登录类型
enum LoginType {
  qq,
  wx,
  iphone,
  qukLogin,
}
