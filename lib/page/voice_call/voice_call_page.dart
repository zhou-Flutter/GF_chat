import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/page/widget.dart/avatar.dart';

class VoiceCallPage extends StatefulWidget {
  VoiceCallPage({Key? key}) : super(key: key);

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        children: [
          SafeArea(
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.all(30.r),
                  width: 70.r,
                  height: 70.r,
                  decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(20.r)),
                  child: Icon(
                    Icons.close_fullscreen,
                    color: Colors.white,
                    size: 40.sp,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 120.h,
          ),
          Container(
            child: Avatar(isSelf: true, size: 200.r),
          ),
          Container(
            padding: EdgeInsets.all(30.r),
            child: Text(
              "flutter",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.sp,
              ),
            ),
          ),
          Spacer(),
          Container(
            child: Text(
              "00:09",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.sp,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  width: 130.r,
                  height: 130.r,
                  decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(30.r)),
                  child: Icon(
                    IconData(0xe6a8, fontFamily: "icons"),
                    size: 60.sp,
                    color: Colors.white,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  width: 130.r,
                  height: 130.r,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30.r)),
                  child: Icon(
                    IconData(0xe670, fontFamily: "icons"),
                    size: 60.sp,
                    color: Colors.white,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  width: 130.r,
                  height: 130.r,
                  decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(30.r)),
                  child: Icon(
                    IconData(0xe71c, fontFamily: "icons"),
                    size: 60.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
