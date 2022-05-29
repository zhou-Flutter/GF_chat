import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_floating/floating/floating.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jverify/jverify.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/http/api.dart';
import 'package:my_chat/http/jv_request.dart';
import 'package:my_chat/model/tencent_api_resp.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/utils/constant.dart';
import 'package:my_chat/utils/generate_test_user_sig.dart';
import 'package:my_chat/utils/tencent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_kit/tencent_kit.dart';

class Login with ChangeNotifier {
  //腾讯QQ APPID
  final String _TENCENT_APPID = '102005320';

  //qq登录信息
  LoginResp? _loginResp;

  //用户ID
  String _userId = "";

  //腾讯 QQ 用户信息
  TencentUserInfoResp? userInfo;

  bool _isVerify = false;

  //全局 悬浮窗
  late Floating floatingOne;

  //极光认证
  Jverify jverify = new Jverify();

  String get selfId => _userId;
  bool get isVerify => _isVerify;

  //登录
  tologin(context) async {
    print(_userId);
    if (_userId == "") {
      Application.router.navigateTo(
        context,
        "/loginPage",
        clearStack: true,
        transition: TransitionType.inFromRight,
      );
    } else {
      GenerateTestUserIMSig usersig = GenerateTestUserIMSig(
        sdkappid: 1400559934,
        key: "a3e290c6599c803789611039131f2283508f2707c8da745934459f123c6b9817",
      );

      String pwdStr = usersig.genSig(identifier: _userId, expire: 86400);
      V2TimCallback data = await TencentImSDKPlugin.v2TIMManager.login(
        userID: _userId,
        userSig: pwdStr,
      );

      if (data.code != 0) {
        Fluttertoast.showToast(msg: "登录信息失效，请重新登录");
        Application.router.navigateTo(
          context,
          "/loginPage",
          clearStack: true,
          transition: TransitionType.inFromRight,
        );
        return;
      } else {
        setUserInfo(context);
        EasyLoading.dismiss();
        //登录成功
        Application.router.navigateTo(
          context,
          "/bottomNav",
          clearStack: true,
          transition: TransitionType.inFromRight,
        );
      }
    }
  }

  /*

     qq登录

   */
  //qq监听
  listenLogin(BaseResp resp, context) {
    if (resp.ret == -2) {
      EasyLoading.dismiss();
      Fluttertoast.showToast(msg: "授权取消");
      return;
    }
    if (resp is LoginResp) {
      _loginResp = resp;
      final String content = 'login: ${resp.openid} - ${resp.accessToken}';
      _userId = resp.openid!;
      saveUserId();
      getUserInfo(context);
    } else if (resp is ShareMsgResp) {
      final String content = 'share: ${resp.ret} - ${resp.msg}';
      Fluttertoast.showToast(msg: "分享监听中");
    }
  }

  //QQ 登录
  qqLogin() async {
    bool isqq = await Tencent.instance.isQQInstalled();
    if (isqq) {
      EasyLoading.show(status: '正在登录...');
      Tencent.instance.login(scope: <String>[TencentScope.GET_SIMPLE_USERINFO]);
    } else {
      Fluttertoast.showToast(msg: "未安装QQ");
    }
  }

  //获取用户信息
  getUserInfo(context) async {
    if ((_loginResp?.isSuccessful ?? false) &&
        !(_loginResp!.isExpired ?? true)) {
      userInfo = await Tencent.instance.getUserInfo(
        appId: _TENCENT_APPID,
        openid: _loginResp!.openid!,
        accessToken: _loginResp!.accessToken!,
      );
      if (userInfo!.isSuccessful) {
        tologin(context);
      } else {
        Fluttertoast.showToast(msg: "${userInfo!.msg}");
      }
    }
  }

  setUserInfo(context) async {
    if (userInfo != null) {
      Provider.of<Friend>(context, listen: false).setSelfInfo(userInfo!);
    }
  }

  // 获取 userId
  saveUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userId", _userId);
  }

  // 获取 userId  进行登录
  getUserID(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      _userId = prefs.getString("userId")!;
      tologin(context);
    } else {
      Application.router.navigateTo(
        context,
        "/loginPage",
        clearStack: true,
        transition: TransitionType.inFromRight,
      );
    }
  }

  /*

    极光认证

  */

  //初始化 平台 状态
  Future<void> initPlatformState() async {
    jverify.addSDKSetupCallBackListener((JVSDKSetupEvent event) {
      print("receive sdk setup call back event :${event.toMap()}");
    });
    jverify.setup(
        appKey: "d0443639315b0672ff9e161b",
        channel: "devloper-default"); // 初始化sdk,  appKey 和 channel 只对ios设置有效
    jverify.setDebugMode(true);

    jverify.checkVerifyEnable().then((map) {
      bool result = map["result"];
      if (result) {
        isInitSuccess();
      } else {
        print("当前网络环境不支持认证");
      }
    });
  }

  /// sdk 初始化是否完成
  void isInitSuccess() {
    jverify.isInitSuccess().then((map) {
      bool result = map["result"];
      if (result) {
        getToken();
      } else {
        print("sdk 初始化失败");
      }
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
      getMobileNumber(_token);
    });
  }

  //获取手机号
  getMobileNumber(token) async {
    Map data = {"token": token};
    // await Api.GetNumber(data).then((e) {
    //   print(e);
    //   _isVerify = true;
    //   notifyListeners();
    // }).catchError((e) {
    //   print("获取失败");
    // });

    await JvRequest.request(Constant.jVerifyUrl, data: data).then((value) {
      print(value);
    }).catchError((e) {
      print(e);
    });
  }
}
