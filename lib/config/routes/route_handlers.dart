import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:my_chat/page/bottomtab/bottom_navigation.dart';
import 'package:my_chat/page/chat/chat_detail.dart';
import 'package:my_chat/page/chat/component/photo_view.dart';
import 'package:my_chat/page/chat/component/video_play.dart';
import 'package:my_chat/page/chat_setting/chat_setting.dart';
import 'package:my_chat/page/contacts/blacklist.dart';
import 'package:my_chat/page/contacts/consent_verified.dart';
import 'package:my_chat/page/friend/add_friend.dart';
import 'package:my_chat/page/friend/component/search_friend.dart';
import 'package:my_chat/page/friend/send_add_page.dart';

import 'package:my_chat/page/friend/friend_info.dart';
import 'package:my_chat/page/contacts/friend_new.dart';
import 'package:my_chat/page/group/create_group.dart';

import 'package:my_chat/page/login/login.dart';
import 'package:my_chat/page/login/mobile_num_login.dart';
import 'package:my_chat/page/self_info/self_info.dart';
import 'package:my_chat/page/self_info/self_qr.dart';
import 'package:my_chat/page/setup/permission.dart';
import 'package:my_chat/page/setup/setup.dart';
import 'package:my_chat/page/splash/splash.dart';
import 'package:my_chat/page/voice_call/voice_call_page.dart';
import 'package:my_chat/page/widget/user_agreement.dart';

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
    userID: args['userID'],
    showName: args['showName'],
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

var selfInfoPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return SelfInfoPage();
});

var selfQrHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return SelfQr();
});

var setUpPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return SetUpPage();
});

var permissionHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return Permission();
});

var chatSettingHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  final args = context?.settings?.arguments as Map;
  return ChatSetting(
    userID: args['userID'],
  );
});
var blackListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return BlackList();
});

var consentVerifiedHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  final args = context?.settings?.arguments as Map;
  return ConsentVerified(
    userID: args['userID'],
  );
});

var createGroupHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return CreateGroup();
});
