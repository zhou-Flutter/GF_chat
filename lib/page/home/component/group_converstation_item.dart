import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/page/home/component/group_avatar.dart';
import 'package:my_chat/page/home/component/msg_status.dart';
import 'package:my_chat/page/home/component/slider_item.dart';
import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/relative_date_format.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GroupConverItem extends StatefulWidget {
  V2TimConversation conversation;
  GroupConverItem({
    required this.conversation,
    Key? key,
  }) : super(key: key);

  @override
  State<GroupConverItem> createState() => _GroupConverItemState();
}

class _GroupConverItemState extends State<GroupConverItem> {
  V2TimConversation? item;
  var createTime; //会话 时间

  var converName = "群聊"; // 群聊会话名称

  List<V2TimGroupMemberFullInfo?> _groupMemberList = [];
  @override
  void initState() {
    super.initState();
    item = widget.conversation;
    createTime = RelativeDateFormat.timeToBefore(item!.lastMessage!.timestamp!);

    setState(() {});
  }

//页面跳转
  _onTap(V2TimConversation item) {
    print("跳转1");
    Provider.of<Chat>(context, listen: false).getGroupMsgList(item, context);
  }

  @override
  Widget build(BuildContext context) {
    return SliderItem(
      isPinned: item!.isPinned!,
      key: UniqueKey(),
      onTap: () {
        _onTap(widget.conversation);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25.r),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(right: 20.r),
              child: GroupAvatar(
                size: 95.r,
                groupMemberList: _groupMemberList,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      widget.conversation.showName!,
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
