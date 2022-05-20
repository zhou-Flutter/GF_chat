import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';

//同意好友验证的页面 暂时不用
class ConsentVerified extends StatefulWidget {
  String? userID;
  ConsentVerified({
    Key? key,
    this.userID,
  }) : super(key: key);

  @override
  State<ConsentVerified> createState() => _ConsentVerifiedState();
}

class _ConsentVerifiedState extends State<ConsentVerified> {
  TextEditingController _textEditingcontroller1 = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: backBtn(context),
        title: Text(
          "通过朋友验证",
          style: TextStyle(fontSize: 30.sp),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 20.r),
        child: Column(
          children: [
            remarks(),
            consent(),
          ],
        ),
      ),
    );
  }

  //同意
  Widget consent() {
    return Container(
      child: InkWell(
        onTap: () {},
        child: Container(
          alignment: Alignment.center,
          width: 250.w,
          padding: EdgeInsets.all(15.r),
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Text(
            "同意",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.sp,
            ),
          ),
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
          ),
        ],
      ),
    );
  }
}
