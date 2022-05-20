import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class MsgCustom extends StatefulWidget {
  V2TimMessage? item;

  MsgCustom({
    this.item,
    Key? key,
  }) : super(key: key);

  @override
  State<MsgCustom> createState() => _MsgCustomState();
}

class _MsgCustomState extends State<MsgCustom> {
  var custom;
  var customMsg;
  CustomType customType = CustomType.NULL;

  @override
  void initState() {
    super.initState();
    custom = widget.item!.customElem!.data;
    if (custom.contains('PROMPT-')) {
      customMsg = custom.replaceAll('PROMPT-', "");
      customType = CustomType.PROMPT;
    } else if (custom.contains('CONCISE-')) {
      customMsg = custom.replaceAll('CONCISE-', "");
      customType = CustomType.CONCISE;
    } else if (custom.contains('VOICECALL-')) {
      customMsg = custom.replaceAll('VOICECALL-', "");
      customType = CustomType.VOICECALL;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Custom(customType);
  }

  Widget Custom(customType) {
    print(customType);
    switch (customType) {
      case CustomType.PROMPT:
        return prompt();
      case CustomType.CONCISE:
        return Container();
      case CustomType.VOICECALL:
        return Container();
      default:
        return Container();
    }
  }

  Widget prompt() {
    return Container(
      padding: EdgeInsets.all(10.r),
      child: Text(
        customMsg,
        style: TextStyle(
          color: Colors.black38,
          fontSize: 25.sp,
        ),
      ),
    );
  }
}

//自定义消息类型
enum CustomType {
  NULL, //未知类型
  PROMPT, //提示类
  CONCISE, //自我介绍，名片类
  VOICECALL, //语音通话时长
}
