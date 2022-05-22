import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';

class Friends {
  V2TimFriendInfo friendInfo;
  String indexLetter; //首字母大写
  bool? isSelect;
  Friends({
    required this.friendInfo,
    this.indexLetter = "#",
    this.isSelect = false,
  });
}
