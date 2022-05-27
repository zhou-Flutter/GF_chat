import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class BlockPerson extends StatefulWidget {
  String? userID;
  BlockPerson({
    Key? key,
    this.userID,
  }) : super(key: key);

  @override
  State<BlockPerson> createState() => _BlockPersonState();
}

class _BlockPersonState extends State<BlockPerson> {
  bool flag = false;

  List<V2TimFriendInfo>? _blackList = [];

  @override
  void initState() {
    super.initState();

    getBlackList();

    print(widget.userID);
  }

  //获取黑名单
  getBlackList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getFriendshipManager()
        .getBlackList();
    if (res.data != null) {
      _blackList = res.data!;

      for (V2TimFriendInfo item in _blackList!) {
        if (item.userID == widget.userID) {
          flag = true;
          setState(() {});
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 10.r),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            "屏蔽此人",
            style: TextStyle(fontSize: 30.sp),
          ),
          const Spacer(),
          Switch(
            value: flag,
            onChanged: (value) {
              if (value) {
                addToBlackList(widget.userID, value);
              } else {
                deleteFromBlackList(widget.userID, value);
              }
            },
          ),
        ],
      ),
    );
  }

  //加入黑名单
  addToBlackList(userID, value) async {
    V2TimValueCallback<List<V2TimFriendOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .addToBlackList(userIDList: [userID]);

    if (res.code == 0) {
      setState(() {
        flag = value;
      });
    }
  }

  // 解除黑名单
  deleteFromBlackList(userID, value) async {
    V2TimValueCallback<List<V2TimFriendOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .deleteFromBlackList(userIDList: [userID]);
    if (res.code == 0) {
      setState(() {
        flag = value;
      });
    }
  }
}
