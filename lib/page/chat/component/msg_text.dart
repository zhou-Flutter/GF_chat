import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_chat/page/widget.dart/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/event_bus.dart';
import 'package:my_chat/utils/text_height.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

//文本消息
class TextMsg extends StatefulWidget {
  V2TimMessage? item;
  TextMsg({
    this.item,
    Key? key,
  }) : super(key: key);

  @override
  State<TextMsg> createState() => _TextMsgState();
}

class _TextMsgState extends State<TextMsg> {
  double height = 70.r;

  var textMsg = "";
  @override
  void initState() {
    super.initState();
    textMsg = widget.item!.textElem!.text!;
  }

  getTextHeight() {
    //计算文本的高
    var dou = TextHegiht.calculateTextHeight(
      context: context,
      value: textMsg,
      fontSize: 28.sp,
      maxWidth: 284.94117678737973,
    );
    if (dou + 30.r > 70.r) {
      height = dou + 30.r;
    }
  }

  @override
  Widget build(BuildContext context) {
    getTextHeight();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r),
      child: Row(
        textDirection:
            widget.item!.isSelf == true ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(
            size: 70.r,
            isSelf: widget.item!.isSelf!,
            faceUrl: widget.item!.faceUrl,
          ),
          SizedBox(
            width: 10.w,
          ),
          triangle(widget.item!.isSelf),
          Flexible(
            child: Container(
              constraints: BoxConstraints(minHeight: 70.r, minWidth: 70.w),
              padding: EdgeInsets.all(15.r),
              decoration: BoxDecoration(
                color: widget.item!.isSelf == true
                    ? HexColor.fromHex('#9370DB')
                    : Colors.white,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: InkWell(
                onTap: () {},
                child: Text(
                  "$textMsg",
                  style: TextStyle(
                    fontSize: 28.sp,
                  ),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: height,
            width: 70.r,
            child: msgStatus(widget.item!.status),
          ),
          SizedBox(
            width: 20.h,
          ),
        ],
      ),
    );
  }

  //消息状态
  Widget msgStatus(state) {
    switch (state) {
      case 0:
        return Container(
            height: 70.r,
            width: 70.r,
            padding: EdgeInsets.all(20.r),
            child: const LoadingIndicator(
              indicatorType: Indicator.lineSpinFadeLoader,
              colors: [Colors.black26],
            ));
      case 2:
        return Container(
          height: 70.r,
          width: 70.r,
        );
      case 3:
        return Container(
          height: 70.r,
          width: 70.r,
          child: Icon(
            Icons.info,
            color: Colors.red,
            size: 40.r,
          ),
        );
      default:
        return Container(
          width: 70.r,
        );
    }
  }

  //会话三角形
  Widget triangle(isSelf) {
    return isSelf == true
        ? Container(
            margin: EdgeInsets.only(top: 20.r),
            transform: Matrix4.skewX(-0.01),
            decoration: BoxDecoration(
              border: Border(
                // 四个值 top right bottom left
                bottom: BorderSide(
                    color: Colors.transparent,
                    width: 12.w,
                    style: BorderStyle.solid),
                left: BorderSide(
                  color: HexColor.fromHex('#9370DB'),
                  width: 13.w,
                  style: BorderStyle.solid,
                ),
                top: BorderSide(
                    color: Colors.transparent,
                    width: 12.w,
                    style: BorderStyle.solid),
              ),
            ),
          )
        : Container(
            margin: EdgeInsets.only(top: 20.r),
            transform: Matrix4.skewX(-0.01),
            decoration: BoxDecoration(
              border: Border(
                // 四个值 top right bottom left
                bottom: BorderSide(
                    color: Colors.transparent,
                    width: 12.w,
                    style: BorderStyle.solid),
                right: BorderSide(
                  color: Colors.white,
                  width: 13.w,
                  style: BorderStyle.solid,
                ),
                top: BorderSide(
                    color: Colors.transparent,
                    width: 12.w,
                    style: BorderStyle.solid),
              ),
            ),
          );
  }
}
