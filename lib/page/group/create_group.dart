import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/model/friends.dart';
import 'package:my_chat/page/contacts/component/friend_list.dart';
import 'package:my_chat/page/group/component/friend_list_choice.dart';
import 'package:my_chat/page/widget/agreement_dialog.dart';
import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_search_param.dart';

class CreateGroup extends StatefulWidget {
  CreateGroup({Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> with WidgetsBindingObserver {
  //输入框文本控制器
  TextEditingController textEditingController = TextEditingController();

  //控制焦点
  final FocusNode _focusNode = FocusNode();

  // 软键盘是否显示
  bool isShowSearch = false;

  //好友列表
  List<V2TimFriendInfo> friendList = [];

  //添加群组的好友
  List<V2TimFriendInfo> groupAddFriend = [];

  //搜索好友列表
  List<Friends> searchFriendList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    friendList = Provider.of<Friend>(context, listen: false).friendList;
    //初始化 键盘监听
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (MediaQuery.of(context).viewInsets.bottom == 0) {
        } else {
          //显示键盘
          isShowSearch = true;
        }
      });
    });
  }

  //创建群聊
  create() {
    Provider.of<Friend>(context, listen: false)
        .createGroup(groupAddFriend, context);
  }

  @override
  Widget build(BuildContext context) {
    List<V2TimFriendInfoResult> friendList =
        Provider.of<Friend>(context, listen: false).searchFriend!;
    for (int i = 0; i < friendList.length; i++) {
      searchFriendList.add(Friends(friendInfo: friendList[i].friendInfo!));
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: backBtn(context),
        centerTitle: true,
        title: Text(
          "发起群聊",
          style: TextStyle(
            fontSize: 30.sp,
          ),
        ),
      ),
      body: Stack(
        children: [
          selectFriends(),
          Positioned(bottom: 0, child: btnSubmit()),
        ],
      ),
    );
  }

  //完成按钮
  Widget btnSubmit() {
    return groupAddFriend.isEmpty
        ? Container(
            alignment: Alignment.centerRight,
            height: 100.h,
            width: MediaQuery.of(context).size.width,
            color: HexColor.fromHex('#f5f5f5'),
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 30.r),
              width: 100.w,
              height: 45.h,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                "完成",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.sp,
                ),
              ),
            ),
          )
        : InkWell(
            onTap: () {
              create();
            },
            child: Container(
              alignment: Alignment.centerRight,
              height: 100.h,
              width: MediaQuery.of(context).size.width,
              color: HexColor.fromHex('#f5f5f5'),
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 30.r),
                width: 100.w,
                height: 45.h,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  "完成",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                  ),
                ),
              ),
            ),
          );
  }

  //搜索输入框
  Widget selectFriends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 100.r,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.black12, width: 1.r),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 15.r, bottom: 15.r, left: 30.r),
                  child: Avatar(isSelf: true, size: 70.r),
                ),
                Row(
                  children: groupAddFriend.map((e) {
                    return Container(
                      padding:
                          EdgeInsets.only(top: 15.r, bottom: 15.r, left: 30.r),
                      child: Avatar(
                          isSelf: false,
                          size: 70.r,
                          faceUrl: e.userProfile!.faceUrl),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 25.r),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.black12, width: 1.r),
            ),
          ),
          child: TextField(
            controller: textEditingController,
            focusNode: _focusNode,
            autofocus: false,
            decoration: const InputDecoration(
              hintText: "搜索",
              hintStyle: TextStyle(
                color: Colors.black54,
              ),
              prefixIcon: Padding(
                padding: EdgeInsetsDirectional.only(end: 5),
                child: Icon(
                  IconData(0xeafe, fontFamily: "icons"),
                  color: Colors.black38,
                  size: 26,
                ),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 10),
              filled: false,
              isCollapsed: true,
              border: InputBorder.none,
            ),
            onChanged: (e) {
              if (e.isNotEmpty) {
                V2TimFriendSearchParam value =
                    V2TimFriendSearchParam(keywordList: [e]);
                Provider.of<Friend>(context, listen: false)
                    .searchFriends(value);
              } else {
                searchFriendList = [];
              }
              setState(() {});
            },
          ),
        ),
        isShowSearch == true ? searchFriend() : friend(),
      ],
    );
  }

  //朋友列表
  Widget friend() {
    return Container(
      height: 1000.h,
      child: FriendListChoice(
        friendList: friendList,
        select: (e) {
          groupAddFriend = e;
          setState(() {});
        },
      ),
    );
  }

  //搜索朋友
  Widget searchFriend() {
    return InkWell(
      onTap: () {
        isShowSearch = false;
        FocusScope.of(context).requestFocus(FocusNode()); // 触摸收起键盘
        setState(() {});
      },
      child: Container(
        height: 1000.h,
        child: textEditingController.text.isEmpty
            ? Container()
            : searchFriendList.isEmpty
                ? Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(top: 60.r),
                    child: Text(
                      "暂无找到与 ${textEditingController.text} 相关的联系人",
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 30.sp,
                      ),
                    ),
                  )
                : ScrollConfiguration(
                    behavior: CusBehavior(),
                    child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: searchFriendList.length,
                        itemBuilder: (context, index) {
                          return friendListItem(searchFriendList[index], index);
                        }),
                  ),
      ),
    );
  }

  //好友列表
  Widget friendListItem(Friends item, index) {
    return Column(
      children: [
        CustomTap(
          tapColor: HexColor.fromHex('#f5f5f5'),
          onTap: () {},
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              checkBox(item, index),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.r, horizontal: 25.r),
                child: Avatar(
                  isSelf: false,
                  size: 75.r,
                  faceUrl: item.friendInfo.userProfile!.faceUrl!,
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

  //选择框
  Widget checkBox(Friends item, index) {
    return Checkbox(
      value: item.isSelect,
      activeColor: Colors.green,
      shape: CircleBorder(),
      onChanged: (value) {
        if (value!) {
          print("选择");
          searchFriendList[index].isSelect = value;
          groupAddFriend.add(item.friendInfo);
        } else {
          print("取消选择");
          searchFriendList[index].isSelect = value;
          groupAddFriend.remove(item.friendInfo);
        }
        setState(() {});
      },
    );
  }
}
