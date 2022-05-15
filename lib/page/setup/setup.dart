import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';

class SetUpPage extends StatefulWidget {
  SetUpPage({Key? key}) : super(key: key);

  @override
  State<SetUpPage> createState() => _SetUpPageState();
}

class _SetUpPageState extends State<SetUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backBtn(context),
        centerTitle: true,
        title: Text(
          "设置",
          style: TextStyle(
            fontSize: 30.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            toolItem(
              onTap: () {},
              title: "账户与安全",
              independent: true,
            ),
            toolItem(
              onTap: () {
                Application.router.navigateTo(
                  context,
                  "/permission",
                  transition: TransitionType.inFromRight,
                );
              },
              title: "权限",
              independent: true,
            ),
            toolItem(
              onTap: () {},
              title: "通用",
              independent: false,
            ),
            toolItem(
              onTap: () {},
              title: "辅助功能",
              independent: false,
            ),
            toolItem(
              onTap: () {},
              title: "帮助与反馈",
              independent: true,
            ),
            toolItem(
              onTap: () {},
              title: "关于",
              independent: false,
              subtitle: "3.6.0",
            ),
            Container(height: 25.h),
            CustomTap(
                onTap: () {},
                tapColor: HexColor.fromHex('#f5f5f5'),
                child: account("切换账号")),
            Container(height: 25.h),
            CustomTap(
              onTap: () {},
              tapColor: HexColor.fromHex('#f5f5f5'),
              child: account("退出"),
            ),
          ],
        ),
      ),
    );
  }

  //账户 切换 退出
  Widget account(title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 25.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$title",
            style: TextStyle(fontSize: 30.sp),
          ),
        ],
      ),
    );
  }
}

class toolItem extends StatefulWidget {
  Function onTap;
  bool? independent;
  String? title;
  String? subtitle;
  toolItem({
    this.title,
    required this.onTap,
    this.independent = true,
    this.subtitle = "",
    Key? key,
  }) : super(key: key);

  @override
  State<toolItem> createState() => _toolItemState();
}

class _toolItemState extends State<toolItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.independent == true
            ? Container(height: 30.h)
            : Divider(
                height: 1.r,
                indent: 30.r,
                color: Colors.black12,
              ),
        CustomTap(
          onTap: widget.onTap,
          tapColor: HexColor.fromHex('#f5f5f5'),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 25.r),
            child: Row(
              children: [
                Text(
                  "${widget.title}",
                  style: TextStyle(fontSize: 30.sp),
                ),
                const Spacer(),
                Text(
                  "${widget.subtitle}",
                  style: TextStyle(
                    color: Colors.black26,
                    fontSize: 25.sp,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
