import 'dart:async';
import 'dart:math';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/floating.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/provider/init_im_sdk_provider.dart';
import 'package:provider/provider.dart';

class Communal extends StatefulWidget {
  Communal({Key? key}) : super(key: key);

  @override
  State<Communal> createState() => _CommunalState();
}

class _CommunalState extends State<Communal> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "社区",
          style: TextStyle(fontSize: 30.sp),
        ),
      ),
      body: Container(
          child: Column(
        children: [
          InkWell(
            onTap: () {
              // Provider.of<InitIMSDKProvider>(context, listen: false)
              //     .showfloat();
              Application.router.navigateTo(
                MyChatApp.navigatorKey.currentState!.context,
                "/voiceCallPage",
                transition: TransitionType.inFromRight,
              );
            },
            child: Text(
              "你好",
              style: TextStyle(
                fontSize: 60.sp,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Provider.of<InitIMSDKProvider>(context, listen: false)
                  .floatclose();
            },
            child: Text(
              "你好",
              style: TextStyle(
                fontSize: 60.sp,
              ),
            ),
          ),
        ],
      )),
    );
  }
}
