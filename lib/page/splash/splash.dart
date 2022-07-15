import 'dart:async';
import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/page/widget/agreement_dialog.dart';

import 'package:my_chat/provider/common_provider.dart';
import 'package:my_chat/provider/init_provider.dart';
import 'package:my_chat/provider/login_provider.dart';
import 'package:my_chat/utils/constant.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with WidgetsBindingObserver {
  int count = 0;
  int? show = null;
  @override
  void initState() {
    super.initState();
    Provider.of<Common>(context, listen: false).getEmojiList(context);
    Provider.of<Common>(context, listen: false).getEmojiList(context);
    Provider.of<Common>(context, listen: false).getlatelyEmo(context);
    WidgetsBinding.instance.addObserver(this);
  }

  _isShowDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt("isShow") == null) {
      _downloadDialog();
    } else {
      Provider.of<Login>(context, listen: false).getUserID(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((mag) {
      //渲染完毕执行
      _isShowDialog();
    });
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: InkWell(
          onTap: () {
            _downloadDialog();
          },
          child: Image.asset(
            Constant.assetsImg + "spash.png",
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  //打开下载提示框
  _downloadDialog() {
    return showDialog(
      barrierDismissible: false, // 屏蔽点击对话框外部自动关闭
      useSafeArea: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          child: AgreementDialog(),
          onWillPop: () async {
            return Future.value(false);
          },
        );
      },
    );
  }
}
