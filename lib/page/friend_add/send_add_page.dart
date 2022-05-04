import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/constant.dart';
import 'package:provider/provider.dart';

class SendAddPage extends StatefulWidget {
  var userID;
  SendAddPage({
    this.userID,
    Key? key,
  }) : super(key: key);

  @override
  State<SendAddPage> createState() => _SendAddPageState();
}

class _SendAddPageState extends State<SendAddPage> {
  TextEditingController _textEditingcontroller = TextEditingController();
  TextEditingController _textEditingcontroller1 = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
          "申请添加好友",
          style: TextStyle(fontSize: 30.sp),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(40.r),
        color: Colors.white,
        child: Column(
          children: [
            validate(),
            SizedBox(height: 20.h),
            remarks(),
            SizedBox(height: 50.h),
            send(),
          ],
        ),
      ),
    );
  }

  //验证消息
  Widget validate() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 10.r),
            child: Text(
              "发送添加朋友申请",
              style: TextStyle(
                color: Colors.black45,
                fontSize: 25.sp,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.r, horizontal: 30.r),
            height: 180.h,
            decoration: BoxDecoration(
              color: HexColor.fromHex('#F8F8FB'),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: TextField(
              controller: _textEditingcontroller,
              maxLines: 3,
              inputFormatters: [LengthLimitingTextInputFormatter(45)],
              style: TextStyle(
                fontSize: 30.sp,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          )
        ],
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
              controller: _textEditingcontroller1,
              maxLines: 1,
              inputFormatters: [LengthLimitingTextInputFormatter(18)],
              style: TextStyle(
                fontSize: 30.sp,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget send() {
    return InkWell(
      onTap: () {
        Provider.of<Chat>(context, listen: false)
            .addFriend(widget.userID, context);
      },
      child: Container(
        alignment: Alignment.center,
        width: 250.w,
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Text(
          "发送",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.sp,
          ),
        ),
      ),
    );
  }
}
