import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:my_chat/page/bottomtab/bottom_navigation.dart';
import 'package:my_chat/page/chat/chat_detail.dart';
import 'package:my_chat/page/chat/component/photo_view.dart';
import 'package:my_chat/page/chat/component/video_play.dart';
import 'package:my_chat/page/friend_add/add_friend.dart';
import 'package:my_chat/page/friend_add/component/search_friend.dart';
import 'package:my_chat/page/friend_add/send_add_page.dart';
import 'package:my_chat/page/friend_info/friend_info.dart';
import 'package:my_chat/page/friend_new/friend_new.dart';

import 'package:my_chat/page/login/login.dart';
import 'package:my_chat/page/login/mobile_num_login.dart';
import 'package:my_chat/page/splash/splash.dart';
import 'package:my_chat/page/voice_call/voice_call_page.dart';
import 'package:my_chat/page/widget.dart/user_agreement.dart';

var splashHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return Splash();
});

var userAgreementHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return UserAgreement();
});

var loginPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return LoginPage();
});

var bottomNavHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return BottomNav();
});

var chatDetailHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  final args = context?.settings?.arguments as Map;
  return ChatDetailPage(
    item: args['item'],
  );
});

var addFriendPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return AddFriendPage();
});

var searchFriendHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return searchFriend();
});

var friendInfoPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return FriendInfoPage();
});

var friendNewPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return FriendNewPage();
});

var mobileNumLoginPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return MobileNumLoginPage();
});

var sendAddPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  final args = context?.settings?.arguments as Map;
  return SendAddPage(
    userID: args['userID'],
  );
});
var videoPlayHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  final args = context?.settings?.arguments as Map;
  return VideoPlay(
    videoMessage: args['videoMessage'],
  );
});

var photosViewHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  final args = context?.settings?.arguments as Map;
  return PhotosView(
    message: args['message'],
  );
});

var voiceCallPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return VoiceCallPage();
});















// var splashAdHandler = Handler(
//     handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
//   final args = context?.settings?.arguments as Map;
//   return SplashAd(splashAd: args["splash_ad"]);
// });

// var moreContentFullSortHandler = Handler(
//     handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
//   final args = context?.settings?.arguments as Map;
//   return MoreContentFullSort(
//     args['type'],
//     args['list_type'],
//     args['title'],
//     isEnterFromHome:
//         args['isEnterFromHome'] != null ? args['isEnterFromHome'] : false,
//   );
// });
