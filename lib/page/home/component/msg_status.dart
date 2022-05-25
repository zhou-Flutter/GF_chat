import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class MsgStatus extends StatefulWidget {
  V2TimMessage v2timLastMsg;
  MsgStatus({
    required this.v2timLastMsg,
    Key? key,
  }) : super(key: key);

  @override
  State<MsgStatus> createState() => _MsgStatusState();
}

class _MsgStatusState extends State<MsgStatus> {
  var lastmsg = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switch (widget.v2timLastMsg.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        lastmsg = widget.v2timLastMsg.textElem!.text!;
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        lastmsg = "[自定义消息]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        lastmsg = "[图片]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        lastmsg = "[语音]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        lastmsg = "[视频]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        lastmsg = "[文件]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        lastmsg = "[表情包]";
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return msgStatus(widget.v2timLastMsg);
  }

  //消息状态
  Widget msgStatus(V2TimMessage v2timMsg) {
    switch (v2timMsg.status) {
      case 0:
        return Row(
          children: [
            Container(
              child: Text(
                "[发送中]",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.sp,
                ),
              ),
            ),
            Container(
              child: Text(
                "${lastmsg}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 25.sp,
                ),
              ),
            )
          ],
        );
      case 2:
        return Container(
          child: Text(
            "${lastmsg}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black45,
              fontSize: 25.sp,
            ),
          ),
        );
      case 3:
        return Row(
          children: [
            Container(
              child: Text(
                "[发送失败]",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.sp,
                ),
              ),
            ),
            Container(
              child: Text(
                lastmsg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 25.sp,
                ),
              ),
            )
          ],
        );
      case 6:
        return Container(
          child: Text(
            v2timMsg.isSelf == true ? "你撤回了一条消息" : "对方撤回了一条消息",
            style: TextStyle(
              color: Colors.black45,
              fontSize: 25.sp,
            ),
          ),
        );
      default:
        return Container();
    }
  }
}
