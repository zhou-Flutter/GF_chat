import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jverify/jverify.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/constant.dart';

class MobileNumLoginPage extends StatefulWidget {
  MobileNumLoginPage({Key? key}) : super(key: key);

  @override
  State<MobileNumLoginPage> createState() => _MobileNumLoginPageState();
}

class _MobileNumLoginPageState extends State<MobileNumLoginPage> {
  TextEditingController _textEditingcontroller = TextEditingController();

  FocusNode? focusNode = FocusNode();

  TextEditingController _textEditingcontroller1 = TextEditingController();

  FocusNode? focusNode1 = FocusNode();

  VerifyCodeSta vCodeSta = VerifyCodeSta.noSend; //验证码发送状态

  bool isSelect = false; //是否选择同意协议

  var _autoCodeText;

  /// 统一 key
  final String f_result_key = "result";

  /// 错误码
  final String f_code_key = "code";

  /// 回调的提示信息，统一返回 flutter 为 message
  final String f_msg_key = "message";

  //初始化极光插件
  final Jverify jverify = new Jverify();

  var maskFormatter = MaskTextInputFormatter(
      mask: '### ### ####',
      filter: {"#": RegExp('[0-9]')},
      type: MaskAutoCompletionType.lazy);

  Timer? _timer;

  int _timeCount = 60;

  bool btnDis = true; //登录按钮禁用

  @override
  void initState() {
    super.initState();
    _textEditingcontroller.addListener(() {
      _textEditingcontroller.value =
          maskFormatter.updateMask(mask: "### ### #####");
      if (_textEditingcontroller.text.length == 12 &&
          _textEditingcontroller1.text.length == 6) {
        btnDis = false;
      } else {
        btnDis = true;
      }
      setState(() {});
    });
    _textEditingcontroller1.addListener(() {
      if (_textEditingcontroller.text.length == 12 &&
          _textEditingcontroller1.text.length == 6) {
        btnDis = false;
      } else {
        btnDis = true;
      }
      setState(() {});
    });
  }

  /// 获取短信验证码
  void getSMSCode() {
    jverify.checkVerifyEnable().then((map) {
      bool result = map[f_result_key];
      if (result) {
        jverify.getSMSCode(phoneNum: "15346983027").then((map) {
          print("获取短信验证码：${map.toString()}");
          int code = map[f_code_key];
          String message = map[f_msg_key];
          _startTimer();
        });
      } else {
        print("网络环境不支持");
      }
    });
  }

  //倒计时
  void _startTimer() {
    vCodeSta = VerifyCodeSta.isSend;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => {
        setState(() {
          if (_timeCount <= 0) {
            vCodeSta = VerifyCodeSta.reSend;
            _autoCodeText = "重新发送";
            _timer!.cancel();
            _timeCount = 60;
          } else {
            _timeCount -= 1;
            _autoCodeText = "$_timeCount" + 's';
          }
        })
      },
    );
  }

  @override
  void deactivate() {
    if (vCodeSta == VerifyCodeSta.isSend) {
      _timer!.cancel();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 50.r),
              child: Text(
                "登陆后更精彩",
                style: TextStyle(
                  fontSize: 50.sp,
                ),
              ),
            ),
            PhoneNumInput(),
            SizedBox(height: 10.h),
            verifyCodeInput(),
            SizedBox(height: 30.h),
            Agreement(),
            SizedBox(height: 40.h),
            MobileNumLogin(),
            SizedBox(height: 40.h),
            Container(
              child: Text(
                "登录遇到问题?",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 25.sp,
                  letterSpacing: 2,
                ),
              ),
            ),
            Spacer(),
            otherLogin(),
          ],
        ),
      ),
    );
  }

  //手机号码输入框
  Widget PhoneNumInput() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 100.r),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.r, color: Colors.black12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(right: 30.r),
            child: Text(
              "+86 ",
              style: TextStyle(
                fontSize: 40.sp,
                color: Colors.black38,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _textEditingcontroller,
              enableInteractiveSelection: true,
              focusNode: focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              cursorColor: Colors.purple,
              cursorHeight: 40.h,
              maxLines: 1,
              inputFormatters: [
                maskFormatter,
                // FilteringTextInputFormatter.allow(RegExp("[0-9.]")), //只允许输入数字
                LengthLimitingTextInputFormatter(12)
              ],
              style: TextStyle(
                letterSpacing: 1,
                fontSize: 40.sp,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "请输入手机号码",
                hintStyle: TextStyle(
                  color: Colors.black12,
                  fontSize: 40.sp,
                ),
                suffixIcon: _textEditingcontroller.text.isNotEmpty
                    ? Container(
                        padding: EdgeInsets.only(top: 10.r),
                        child: IconButton(
                          onPressed: () {
                            _textEditingcontroller.clear();
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.grey,
                            size: 30.r,
                          ),
                        ),
                      )
                    : null,
              ),
              onChanged: (e) {
                if (e.length == 12) {
                  focusNode1!.requestFocus();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  //验证码输入框
  Widget verifyCodeInput() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 100.r),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.r, color: Colors.black12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _textEditingcontroller1,
              focusNode: focusNode1,
              keyboardType: TextInputType.number,
              cursorColor: Colors.purple,
              cursorHeight: 40.h,
              maxLines: 1,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9.]")), //只允许输入数字
                LengthLimitingTextInputFormatter(6)
              ],
              style: TextStyle(
                fontSize: 40.sp,
                letterSpacing: 3,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "请输入验证码",
                hintStyle: TextStyle(
                  color: Colors.black12,
                  fontSize: 40.sp,
                ),
                suffixIcon: _textEditingcontroller.text.length == 12
                    ? Container(
                        padding: EdgeInsets.only(top: 20.r),
                        child: VerifyCodeBtn(),
                      )
                    : null,
              ),
              onChanged: (e) {},
            ),
          ),
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
                        border: Border.all(width: 1, color: Colors.black),
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                    )
                  : Container(
                      height: 25.w,
                      width: 25.h,
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
                  fontSize: 25.sp,
                  color: Colors.black,
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
                      color: Colors.black,
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

  //登录按钮
  Widget MobileNumLogin() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        InkWell(
          onTap: () {
            Fluttertoast.showToast(msg: "模拟登录");
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(15),
            width: 550.w,
            decoration: BoxDecoration(
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
              "登录",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        Positioned(
          child: btnDis == false
              ? Container()
              : InkWell(
                  onTap: () {},
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(15),
                    width: 550.w,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "登录",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
        )
      ],
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
                    "--其他方式登录--",
                    style: TextStyle(
                      color: Colors.black26,
                      fontSize: 25.sp,
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {},
                        child: Container(
                          padding: EdgeInsets.all(20.r),
                          width: 100.r,
                          height: 100.r,
                          child:
                              Image.asset(Constant.assetsImg + "login_wx.png"),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.all(20.r),
                          width: 100.r,
                          height: 100.r,
                          child:
                              Image.asset(Constant.assetsImg + "login_qq.png"),
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

  Widget VerifyCodeBtn() {
    switch (vCodeSta) {
      case VerifyCodeSta.noSend:
        return InkWell(
          onTap: () {
            print("点击获取验证码，倒计时");
            Fluttertoast.showToast(msg: "模拟发送，因为政策原因，暂无法发送验证码");
            // getSMSCode();
            _startTimer();
          },
          child: Text(
            "获取验证码",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 30.sp,
            ),
          ),
        );
        break;
      case VerifyCodeSta.isSend:
        return Text(
          "($_autoCodeText)",
          style: TextStyle(
            fontSize: 30.sp,
            color: Colors.black38,
          ),
        );
        break;
      case VerifyCodeSta.reSend:
        return InkWell(
          onTap: () {
            _startTimer();
          },
          child: Text(
            "重新发送",
            style: TextStyle(
              fontSize: 30.sp,
              color: Colors.black38,
            ),
          ),
        );
        break;
      default:
    }
    return Container();
  }
}

enum VerifyCodeSta {
  noSend, //未发送
  isSend, // 发送中倒计时
  reSend, // 重新发送
}
