import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';

class Remark extends StatefulWidget {
  String userID;
  Remark({
    Key? key,
    required this.userID,
  }) : super(key: key);

  @override
  State<Remark> createState() => _RemarkState();
}

class _RemarkState extends State<Remark> {
  //输入框文本控制器
  TextEditingController _textEditingcontroller = TextEditingController();
  V2TimFriendInfoResult? friendInfo;
  //控制焦点
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    getRemark();
  }

  getRemark() async {
    friendInfo = await Friend.getFriendsInfo(widget.userID);
    if (friendInfo != null) {
      if (friendInfo!.friendInfo!.friendRemark!.length == 0) {
        _textEditingcontroller.text =
            friendInfo!.friendInfo!.userProfile!.nickName!;
      } else {
        _textEditingcontroller.text = friendInfo!.friendInfo!.friendRemark!;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: backBtn(context),
        centerTitle: true,
        title: Text("好友备注"),
        actions: [
          commitBtn(),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(40.r),
        child: Column(
          children: [
            remarks(),
          ],
        ),
      ),
    );
  }

  //备注
  Widget remarks() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 10.r),
            child: Text(
              "设置备注",
              style: TextStyle(
                color: Colors.black45,
                fontSize: 25.sp,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            decoration: BoxDecoration(
              color: HexColor.fromHex('#F8F8FB'),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: TextField(
              controller: _textEditingcontroller,
              maxLines: 1,
              inputFormatters: [LengthLimitingTextInputFormatter(18)],
              style: TextStyle(
                fontSize: 30.sp,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (e) {
                setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }

  //完成按钮
  Widget commitBtn() {
    return Center(
      child: _textEditingcontroller.text.length == 0
          ? Container(
              margin: EdgeInsets.only(right: 30.r),
              padding: EdgeInsets.symmetric(vertical: 5.r, horizontal: 10.r),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                "完成",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.sp,
                ),
              ),
            )
          : InkWell(
              onTap: () {
                Provider.of<Friend>(context, listen: false).setFriendInfo(
                    widget.userID, _textEditingcontroller.text, context);
              },
              child: Container(
                margin: EdgeInsets.only(right: 30.r),
                padding: EdgeInsets.symmetric(vertical: 5.r, horizontal: 10.r),
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
}
