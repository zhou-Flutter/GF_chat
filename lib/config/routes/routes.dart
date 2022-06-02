import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/config/routes/route_handlers.dart';
import 'package:my_chat/page/widget/not_found_page.dart';

class Routes {
  // 路由管理
  static FluroRouter? router;

  static String splash = "/";
  static String userAgreement = "/userAgreement"; //用户协议
  static String loginPage = "/loginPage";
  static String bottomNav = "/bottomNav"; //底部tab
  static String chatDetail = "/chatDetail"; //聊天详情
  static String addFriendPage = "/addFriendPage";
  static String searchFriend = "/searchFriend";
  static String friendInfoPage = "/friendInfoPage";
  static String friendNewPage = "/friendNewPage";
  static String mobileNumLoginPage = "/mobileNumLoginPage"; //手机号登录界面
  static String sendAddPage = "/sendAddPage"; //发送添加好友页面
  static String videoPlay = "/videoPlay";
  static String photosView = "/photosView";
  static String voiceCallPage = "/voiceCallPage";
  static String selfInfoPage = "/selfInfoPage";
  static String selfQr = "/selfQr"; //二维码界面
  static String setUpPage = "/setUpPage"; //设置界面
  static String permission = "/permission"; //权限
  static String chatSetting = "/chatSetting"; //聊天设置
  static String blackList = "/blackList"; //黑名单
  static String consentVerified = "/consentVerified"; //同意验证加好友
  static String createGroup = "/createGroup"; //创建群聊
  static String groupList = "/groupList"; //群聊列表
  static String groupChatPage = "/groupChatPage"; //群聊页面
  static String groupChatSetting = "/groupChatSetting"; //群聊设置
  static String search = "/search"; //搜索
  static String remark = "/remark"; //好友备注

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return NotFoundPage();
    });

    router.define(splash, handler: splashHandler);
    router.define(userAgreement, handler: userAgreementHandler);
    router.define(loginPage, handler: loginPageHandler);
    router.define(bottomNav, handler: bottomNavHandler);
    router.define(chatDetail, handler: chatDetailHandler);
    router.define(addFriendPage, handler: addFriendPageHandler);
    router.define(searchFriend, handler: searchFriendHandler);
    router.define(friendInfoPage, handler: friendInfoPageHandler);
    router.define(friendNewPage, handler: friendNewPageHandler);
    router.define(mobileNumLoginPage, handler: mobileNumLoginPageHandler);
    router.define(sendAddPage, handler: sendAddPageHandler);
    router.define(videoPlay, handler: videoPlayHandler);
    router.define(photosView, handler: photosViewHandler);
    router.define(voiceCallPage, handler: voiceCallPageHandler);
    router.define(selfInfoPage, handler: selfInfoPageHandler);
    router.define(selfQr, handler: selfQrHandler);
    router.define(setUpPage, handler: setUpPageHandler);
    router.define(permission, handler: permissionHandler);
    router.define(chatSetting, handler: chatSettingHandler);
    router.define(blackList, handler: blackListHandler);
    router.define(consentVerified, handler: consentVerifiedHandler);
    router.define(createGroup, handler: createGroupHandler);
    router.define(groupList, handler: groupListHandler);
    router.define(groupChatPage, handler: groupChatPageHandler);
    router.define(groupChatSetting, handler: groupChatSettingHandler);
    router.define(search, handler: searchHandler);
    router.define(remark, handler: remarkHandler);
  }

  // 对参数进行encode，解决参数中有特殊字符
  static Future navigateTo(BuildContext context, String path,
      {Map<String, dynamic>? params,
      TransitionType transition = TransitionType.native}) {
    String query = "";
    if (params != null) {
      int index = 0;
      for (var key in params.keys) {
        var value = Uri.encodeComponent(params[key]);
        if (index == 0) {
          query = "?";
        } else {
          query = query + "\&";
        }
        query += "$key=$value";
        index++;
      }
    }
    path = path + query;
    return router!.navigateTo(context, path, transition: transition);
  }
}
