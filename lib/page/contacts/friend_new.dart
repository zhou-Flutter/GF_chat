import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';

import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:my_chat/utils/constant.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';

class FriendNewPage extends StatefulWidget {
  const FriendNewPage({Key? key}) : super(key: key);

  @override
  State<FriendNewPage> createState() => _FriendNewPageState();
}

class _FriendNewPageState extends State<FriendNewPage> {
  List<V2TimFriendApplication?>? applicationList = [];
  @override
  void initState() {
    super.initState();
    applicationList =
        Provider.of<Friend>(context, listen: false).applicationList;
    Provider.of<Friend>(context, listen: false).setFriendApplicationRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            Constant.assetsImg + 'back_blc.png',
            width: 40.w,
          ),
          onPressed: () {
            Application.router.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          "好友申请",
          style: TextStyle(
            fontSize: 30.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: applicationList!.isEmpty
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: 200.h,
                color: Colors.white,
                child: Center(
                  child: Text(
                    "暂无好友申请",
                    style: TextStyle(
                      fontSize: 32.sp,
                      color: Colors.black45,
                    ),
                  ),
                ))
            : Column(
                children: [
                  search(),
                  Column(
                    children: applicationList!.map((e) {
                      return blackListItem(e);
                    }).toList(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget blackListItem(V2TimFriendApplication? item) {
    print(item!.userID);
    print(item.type);

    return CustomTap(
      tapColor: HexColor.fromHex('#f5f5f5'),
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.r, horizontal: 30.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Avatar(
              isSelf: false,
              size: 85.r,
              faceUrl: item.faceUrl,
            ),
            SizedBox(width: 25.w),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${item.nickname}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 30.sp,
                    ),
                  ),
                  Text(
                    "${item.addWording}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 25.sp,
                      color: Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            verifyBtn(item),
          ],
        ),
      ),
    );
  }

  //搜索
  Widget search() {
    return Container(
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.only(right: 25.r, left: 25.r, bottom: 25.r),
        padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 15.r),
        decoration: BoxDecoration(
          color: HexColor.fromHex('#F5F7FB'),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: InkWell(
          onTap: () {
            print("跳转到搜索页面");
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                IconData(0xeafe, fontFamily: "icons"),
                color: Colors.black26,
              ),
              Text(
                "搜索",
                style: TextStyle(
                  color: Colors.black26,
                  fontSize: 28.sp,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //验证按钮
  Widget verifyBtn(V2TimFriendApplication item) {
    print(item.type);
    switch (item.type) {
      case 1:
        return InkWell(
          onTap: () {
            Provider.of<Friend>(context, listen: false)
                .acceptFriendApplication(item.userID, context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 3.r),
            decoration: BoxDecoration(
              color: HexColor.fromHex('#f5f5f5'),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              "同意",
              style: TextStyle(
                fontSize: 25.sp,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      case 2:
        return InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 20.r),
            child: Text(
              "等待验证",
              style: TextStyle(
                fontSize: 30.sp,
                color: Colors.black12,
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }
}
