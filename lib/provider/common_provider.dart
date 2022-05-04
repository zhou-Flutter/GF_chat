import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//APP 全局常用数据
class Common with ChangeNotifier {
  //
  List<dynamic> _emojiList = []; //表情包数据

  List<dynamic> _latelyEmo = []; //最近常用的表情包
  int _soundPathName = 0;

  List<dynamic> get emojiList => _emojiList;
  List<dynamic> get latelyEmo => _latelyEmo;

  int get soundPathName => _soundPathName;

  //获取 表情包数据
  getEmojiList(context) async {
    var s = await DefaultAssetBundle.of(context)
        .loadString("assets/emoji_list.json");
    _emojiList = json.decode(s.toString());
  }

  //获取 最近常用的表情包
  getlatelyEmo(context) async {
    var s = await DefaultAssetBundle.of(context)
        .loadString("assets/emoji_list.json");
    _latelyEmo = json.decode(s.toString());
  }

  //存储最近常用的表情包
  savelatelyEmo(latelyEmo) async {
    // _latelyEmo.add(latelyEmo);
  }

  //获取音频路径
  getSoundPathName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt("soundPathName") != null) {
      _soundPathName = prefs.getInt("soundPathName")!;
    }
  }

  //存储音频路径
  setSoundPathName(sound) async {
    _soundPathName = sound++;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("soundPathName", sound);
  }
}
