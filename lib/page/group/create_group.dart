import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/page/contacts/component/friend_list.dart';
import 'package:my_chat/page/group/component/friend_list_choice.dart';
import 'package:my_chat/page/widget/agreement_dialog.dart';
import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';

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

  List<V2TimFriendInfo> friendList = []; //好友列表

  //添加群组的好友
  List<V2TimFriendInfo> groupAddFriend = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    friendList = Provider.of<Chat>(context, listen: false).friendList;
    //初始化 键盘监听
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        if (MediaQuery.of(context).viewInsets.bottom == 0) {
        } else {
          //显示键盘
          isShowSearch = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
    return InkWell(
      onTap: () {},
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
          height: 150.r,
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
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: groupAddFriend.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding:
                          EdgeInsets.only(top: 15.r, bottom: 15.r, left: 30.r),
                      child: Avatar(
                          isSelf: false,
                          size: 70.r,
                          faceUrl: groupAddFriend[index].userProfile!.faceUrl),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 25.r),
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
              setState(() {});
            },
          ),
        ),
        contacts(),
      ],
    );
  }

  //联系人
  Widget contacts() {
    return Container(
      child: isShowSearch == true ? searchFriend() : friend(),
    );
  }

  //朋友列表
  Widget friend() {
    return FriendListChoice(
      friendList: friendList,
      select: (e) {
        groupAddFriend = e;
        setState(() {});
      },
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
        child: ScrollConfiguration(
          behavior: CusBehavior(),
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              Text("你好", style: TextStyle(fontSize: 100)),
              Text("你好", style: TextStyle(fontSize: 100)),
              Text("你好", style: TextStyle(fontSize: 100)),
              Text("你好", style: TextStyle(fontSize: 100)),
              Text("你好", style: TextStyle(fontSize: 100)),
              Text("你好", style: TextStyle(fontSize: 100)),
              Text("你好", style: TextStyle(fontSize: 100)),
              Text("你好", style: TextStyle(fontSize: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
