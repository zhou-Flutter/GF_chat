import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/page/home/component/msg_status.dart';
import 'package:my_chat/page/home/component/slider_item.dart';
import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/relative_date_format.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';

class C2cConverItem extends StatefulWidget {
  V2TimConversation conversation;
  C2cConverItem({
    required this.conversation,
    Key? key,
  }) : super(key: key);

  @override
  State<C2cConverItem> createState() => _C2cConverItemState();
}

class _C2cConverItemState extends State<C2cConverItem> {
  V2TimConversation? item;
  var createTime = ""; //会话 时间
  @override
  void initState() {
    super.initState();
    item = widget.conversation;
    if (item!.lastMessage != null) {
      createTime =
          RelativeDateFormat.timeToBefore(item!.lastMessage!.timestamp!);
      setState(() {});
    }
  }

  //页面跳转
  _onTap(V2TimConversation item) {
    Provider.of<Chat>(context, listen: false)
        .getC2CMsgList(item.userID, context);
  }

  @override
  Widget build(BuildContext context) {
    return SliderItem(
      isPinned: item!.isPinned!,
      key: UniqueKey(),
      onTap: () {
        _onTap(item!);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25.r),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(right: 20.r),
              child: Avatar(
                size: 95.r,
                isSelf: false,
                faceUrl: item!.faceUrl,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      "${item!.showName}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  item!.draftText != null
                      ? drafText(item!.draftText)
                      : item!.lastMessage == null
                          ? Container()
                          : MsgStatus(
                              v2timLastMsg: item!.lastMessage!,
                            )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${createTime}",
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.black26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  item!.unreadCount == 0
                      ? Container()
                      : Container(
                          width: 30.r,
                          height: 30.r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Text(
                            "${item!.unreadCount}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                            ),
                          ),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
      toppingChild: item!.isPinned == true
          ? Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {
                  Provider.of<Chat>(context, listen: false)
                      .pinConversation(item!.conversationID, false);
                },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 10.r),
                  child: Text(
                    "取消置顶",
                    style: TextStyle(
                      fontSize: 30.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          : Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  Provider.of<Chat>(context, listen: false)
                      .pinConversation(item!.conversationID, true);
                },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.blue,
                  child: Text(
                    "置顶",
                    style: TextStyle(
                      fontSize: 30.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              )),
      deleteChild: Expanded(
        flex: 2,
        child: InkWell(
          onTap: () {
            Provider.of<Chat>(context, listen: false)
                .deleteConversation(item!.conversationID);
          },
          child: Container(
            alignment: Alignment.center,
            color: Colors.red,
            child: Text(
              "删除",
              style: TextStyle(
                fontSize: 30.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  //草稿箱
  Widget drafText(draftText) {
    return Container(
      child: RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: '[草稿箱]',
          style: TextStyle(
            fontSize: 25.sp,
            color: Colors.red,
          ),
          children: [
            const TextSpan(text: ' '),
            TextSpan(
              text: '$draftText',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 25.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
