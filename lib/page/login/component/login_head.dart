import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/utils/constant.dart';

class LoginHead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Container(
            width: 200.r,
            height: 200.r,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10), //弧度
              child: Image.asset(
                Constant.assetsImg + "logo.png",
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              "遇见最好的朋友",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 35.sp,
              ),
            ),
          )
        ],
      ),
    );
  }
}
