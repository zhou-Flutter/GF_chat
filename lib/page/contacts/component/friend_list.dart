import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:my_chat/model/friends.dart';
import 'package:my_chat/page/contacts/contacts.dart';
import 'package:my_chat/page/widget/agreement_dialog.dart';
import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';

class FriendList extends StatefulWidget {
  List<V2TimFriendInfo> friendList;

  FriendList({
    Key? key,
    required this.friendList,
  }) : super(key: key);

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  List<V2TimFriendInfo> friendList = [];

  List<Friends> friends = [];

  @override
  void initState() {
    super.initState();
    friendList = widget.friendList;
    for (int i = 0; i < friendList.length; i++) {
      if (friendList[i].friendRemark == "") {
        //根据userName 排序
        String name = friendList[i].userProfile!.nickName!;
        var nameFirst = PinyinHelper.getFirstWordPinyin(name);
        bool isABC = RegExp(r'[a-zA-Z]+').hasMatch(nameFirst);
        if (isABC) {
          //转大写
          var cap = nameFirst.toUpperCase();
          friends.add(Friends(friendInfo: friendList[i], indexLetter: cap));
        } else {
          //转 #
          friends.add(Friends(friendInfo: friendList[i], indexLetter: "#"));
        }
      } else {
        //friendRemark 排序
        String name = friendList[i].friendRemark!;
        var nameFirst = PinyinHelper.getFirstWordPinyin(name);
        bool isABC = RegExp(r'[a-zA-Z]+').hasMatch(nameFirst);
        if (isABC) {
          //转大写
          var cap = nameFirst.toUpperCase();
          friends.add(Friends(friendInfo: friendList[i], indexLetter: cap));
        } else {
          //转 #
          friends.add(Friends(friendInfo: friendList[i], indexLetter: "#"));
        }
      }
    }

    friends.sort((Friends a, Friends b) {
      if (a.indexLetter == '#') {
        return 1;
      }
      if (b.indexLetter == '#') {
        return 0;
      }
      return a.indexLetter.compareTo(b.indexLetter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: CusBehavior(),
      child: ListView.builder(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          return friendListItem(friends[index], index);
        },
      ),
    );
  }

//好友列表
  Widget friendListItem(Friends item, index) {
    bool isshow = true;
    if (index != 0) {
      if (item.indexLetter == friends[index - 1].indexLetter) {
        isshow = false;
      }
    }
    return Column(
      children: [
        isshow == true
            ? Container(
                alignment: Alignment.centerLeft,
                height: 40.h,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(left: 25.r),
                color: HexColor.fromHex('#f5f5f5'),
                child: Text(
                  item.indexLetter,
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 25.sp,
                  ),
                ),
              )
            : Container(),
        CustomTap(
          tapColor: HexColor.fromHex('#f5f5f5'),
          onTap: () {
            Provider.of<Friend>(context, listen: false)
                .getFriendsInfo(item.friendInfo.userProfile!.userID, context);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.r, horizontal: 25.r),
                child: Avatar(
                  isSelf: false,
                  size: 75.r,
                  faceUrl: item.friendInfo.userProfile!.faceUrl,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10.r),
                child: Text(
                  "${item.friendInfo.userProfile!.nickName}",
                  style: TextStyle(fontSize: 30.sp),
                ),
              )
            ],
          ),
        ),
        Divider(
          indent: 100.r,
          height: 1.r,
          color: Colors.black12,
        ),
      ],
    );
  }
}
