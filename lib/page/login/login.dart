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

class _LoginPageState extends State<LoginPage> {
  bool isSelect = false; //是否选择同意协议

  final String _TENCENT_APPID = '102005320';

  StreamSubscription<BaseResp>? _respSubs;

  //初始化极光插件
  final Jverify jverify = new Jverify();

  /// 统一 key
  final String f_result_key = "683e39a84c5223571f27216e";

  @override
  void initState() {
    super.initState();

    //qq登录监听
    _respSubs = Tencent.instance.respStream().listen((BaseResp resp) {
      Provider.of<InitIMSDKProvider>(context, listen: false)
          .listenLogin(resp, context);
    });
    initPlatformState();
  }

  //初始化 平台 状态
  Future<void> initPlatformState() async {
    jverify.addSDKSetupCallBackListener((JVSDKSetupEvent event) {
      print("receive sdk setup call back event :${event.toMap()}");
    });
    jverify.setup(
        appKey: "683e39a84c5223571f27216e",
        channel: "devloper-default"); // 初始化sdk,  appKey 和 channel 只对ios设置有效
    jverify.setDebugMode(true);

    jverify.checkVerifyEnable().then((map) {
      bool result = map["result"];
      if (result) {
        print("认证");
        // 当前网络环境支持认证
      } else {
        print("不认证");
        // 当前网络环境不支持认证
      }
    });
    isInitSuccess();
  }

  /// sdk 初始化是否完成
  void isInitSuccess() {
    jverify.isInitSuccess().then((map) {
      print(map);
      bool result = map["result"];
      setState(() {
        if (result) {
          getToken();
        } else {
          print("初始换失败");
        }
      });
    });
  }

  ///获取Token
  void getToken() {
    jverify.getToken().then((map) {
      print(map);
      int _code = map["code"]; // 返回码，2000代表获取成功，其他为失败，详见错误码描述
      String _token = map[
          "content"]; // 成功时为token，可用于调用验证手机号接口。token有效期为1分钟，超过时效需要重新获取才能使用。失败时为失败信息
      String _operator =
          map["operator"]; // 成功时为对应运营商，CM代表中国移动，CU代表中国联通，CT代表中国电信。失败时可能为null
      getPhoneNum(_token);
    });
  }

  //获取手机号
  getPhoneNum(loginToken) async {
    jverify.preLogin().then((map) {
      print("意见与区号");
      print(map);
      // int _code = map["code"]; // 返回码，2000代表获取成功，其他为失败，详见错误码描述
      // String _token = map[
      //     "content"]; // 成功时为token，可用于调用验证手机号接口。token有效期为1分钟，超过时效需要重新获取才能使用。失败时为失败信息
      // String _operator =
      //     map["operator"]; // 成功时为对应运营商，CM代表中国移动，CU代表中国联通，CT代表中国电信。失败时可能为null
      // getPhoneNum(_token);
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
            case LoginType.qukLogin:
              //手机号码登录
              Fluttertoast.showToast(msg: "一键登录手机号");
              loginAuth();
              break;
            default:
          }
        });
      },
    );
  }

  /// SDK 请求授权一键登录
  void loginAuth() {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    bool isiOS = Platform.isIOS;

    /// 自定义授权的 UI 界面，以下设置的图片必须添加到资源文件里，
    /// android项目将图片存放至drawable文件夹下，可使用图片选择器的文件名,例如：btn_login.xml,入参为"btn_login"。
    /// ios项目存放在 Assets.xcassets。
    ///
    JVUIConfig uiConfig = JVUIConfig();
    // uiConfig.authBGGifPath = "main_gif";

    //uiConfig.navHidden = true;
    uiConfig.navColor = Colors.red.value;
    uiConfig.navText = "登录";
    uiConfig.navTextColor = Colors.blue.value;
    // uiConfig.navReturnImgPath = "return_bg"; //图片必须存在

    uiConfig.logoWidth = 100;
    uiConfig.logoHeight = 80;
    //uiConfig.logoOffsetX = isiOS ? 0 : null;//(screenWidth/2 - uiConfig.logoWidth/2).toInt();
    uiConfig.logoOffsetY = 10;
    uiConfig.logoVerticalLayoutItem = JVIOSLayoutItem.ItemSuper;
    uiConfig.logoHidden = false;
    // uiConfig.logoImgPath = "logo";

    uiConfig.numberFieldWidth = 200;
    uiConfig.numberFieldHeight = 40;
    //uiConfig.numFieldOffsetX = isiOS ? 0 : null;//(screenWidth/2 - uiConfig.numberFieldWidth/2).toInt();
    uiConfig.numFieldOffsetY = isiOS ? 20 : 120;
    uiConfig.numberVerticalLayoutItem = JVIOSLayoutItem.ItemLogo;
    uiConfig.numberColor = Colors.blue.value;
    uiConfig.numberSize = 18;

    uiConfig.sloganOffsetY = isiOS ? 20 : 160;
    uiConfig.sloganVerticalLayoutItem = JVIOSLayoutItem.ItemNumber;
    uiConfig.sloganTextColor = Colors.black.value;
    uiConfig.sloganTextSize = 15;
//        uiConfig.slogan
    //uiConfig.sloganHidden = 0;

    uiConfig.logBtnWidth = 220;
    uiConfig.logBtnHeight = 50;
    //uiConfig.logBtnOffsetX = isiOS ? 0 : null;//(screenWidth/2 - uiConfig.logBtnWidth/2).toInt();
    uiConfig.logBtnOffsetY = isiOS ? 20 : 230;
    uiConfig.logBtnVerticalLayoutItem = JVIOSLayoutItem.ItemSlogan;
    uiConfig.logBtnText = "登录按钮";
    uiConfig.logBtnTextColor = Colors.brown.value;
    uiConfig.logBtnTextSize = 16;
    // uiConfig.loginBtnNormalImage = "login_btn_normal"; //图片必须存在
    // uiConfig.loginBtnPressedImage = "login_btn_press"; //图片必须存在
    // uiConfig.loginBtnUnableImage = "login_btn_unable"; //图片必须存在

    uiConfig.privacyHintToast = true; //only android 设置隐私条款不选中时点击登录按钮默认显示toast。

    uiConfig.privacyState = true; //设置默认勾选
    uiConfig.privacyCheckboxSize = 20;
    // uiConfig.checkedImgPath = "check_image"; //图片必须存在
    // uiConfig.uncheckedImgPath = "uncheck_image"; //图片必须存在
    uiConfig.privacyCheckboxInCenter = true;
    //uiConfig.privacyCheckboxHidden = false;

    //uiConfig.privacyOffsetX = isiOS ? (20 + uiConfig.privacyCheckboxSize) : null;
    uiConfig.privacyOffsetY = 15; // 距离底部距离
    uiConfig.privacyVerticalLayoutItem = JVIOSLayoutItem.ItemSuper;
    uiConfig.clauseName = "协议1";
    uiConfig.clauseUrl = "http://www.baidu.com";
    uiConfig.clauseBaseColor = Colors.black.value;
    uiConfig.clauseNameTwo = "协议二";
    uiConfig.clauseUrlTwo = "http://www.hao123.com";
    uiConfig.clauseColor = Colors.red.value;
    uiConfig.privacyText = ["1极", "2光", "3认", "4证"];
    uiConfig.privacyTextSize = 13;
    //uiConfig.privacyWithBookTitleMark = true;
    //uiConfig.privacyTextCenterGravity = false;
    uiConfig.authStatusBarStyle = JVIOSBarStyle.StatusBarStyleDarkContent;
    uiConfig.privacyStatusBarStyle = JVIOSBarStyle.StatusBarStyleDefault;
    uiConfig.modelTransitionStyle = JVIOSUIModalTransitionStyle.CrossDissolve;

    uiConfig.statusBarColorWithNav = true;
    uiConfig.virtualButtonTransparent = true;

    uiConfig.privacyStatusBarColorWithNav = true;
    uiConfig.privacyVirtualButtonTransparent = true;

    uiConfig.needStartAnim = true;
    uiConfig.needCloseAnim = true;
    uiConfig.enterAnim = "activity_slide_enter_bottom";
    uiConfig.exitAnim = "activity_slide_exit_bottom";

    uiConfig.privacyNavColor = Colors.red.value;
    uiConfig.privacyNavTitleTextColor = Colors.blue.value;
    uiConfig.privacyNavTitleTextSize = 16;

    uiConfig.privacyNavTitleTitle = "ios lai le"; //only ios
    uiConfig.privacyNavTitleTitle1 = "协议11 web页标题";
    uiConfig.privacyNavTitleTitle2 = "协议22 web页标题";
    // uiConfig.privacyNavReturnBtnImage = "return_bg"; //图片必须存在;

    //弹框模式
    // JVPopViewConfig popViewConfig = JVPopViewConfig();
    // popViewConfig.width = (screenWidth - 100.0).toInt();
    // popViewConfig.height = (screenHeight - 150.0).toInt();
    //
    // uiConfig.popViewConfig = popViewConfig;

    /// 添加自定义的 控件 到授权界面
    List<JVCustomWidget> widgetList = [];

    /// 步骤 1：调用接口设置 UI
    jverify.setCustomAuthorizationView(true, uiConfig,
        landscapeConfig: uiConfig, widgets: widgetList);

    /// 步骤 2：调用一键登录接口

    /// 方式一：使用同步接口 （如果想使用异步接口，则忽略此步骤，看方式二）
    /// 先，添加 loginAuthSyncApi 接口回调的监听
    jverify.addLoginAuthCallBackListener((event) {
      print(
          "通过添加监听，获取到 loginAuthSyncApi 接口返回数据，code=${event.code},message = ${event.message},operator = ${event.operator}");
    });

    /// 再，执行同步的一键登录接口
    jverify.loginAuthSyncApi(autoDismiss: true);
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
      case LoginType.qukLogin:
        //手机号码登录
        Fluttertoast.showToast(msg: "一键登录手机号");
        getToken();
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
                    QuickLogin(),
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
            )
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
