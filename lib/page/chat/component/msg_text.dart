import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:my_chat/utils/event_bus.dart';
import 'package:my_chat/utils/text_height.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class ItemModel {
  int id;
  String title;
  IconData icon;
  ItemModel(
    this.id,
    this.title,
    this.icon,
  );
}

//文本消息
class TextMsg extends StatefulWidget {
  V2TimMessage? item;
  bool isGroup;
  TextMsg({
    this.item,
    required this.isGroup,
    Key? key,
  }) : super(key: key);

  @override
  State<TextMsg> createState() => _TextMsgState();
}

class _TextMsgState extends State<TextMsg> {
  double height = 70.r;

  var textMsg = "";

  List<ItemModel> menuItems = [
    ItemModel(1, '复制', Icons.content_copy),
    ItemModel(2, '删除', Icons.delete),
    ItemModel(3, '转发', Icons.send),
    ItemModel(4, '撤回', Icons.replay),
  ];

  final CustomPopupMenuController _popupMenucontroller =
      CustomPopupMenuController();

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

  //选择菜单
  _selectMenu(id) {
    switch (id) {
      case 1:
        Clipboard.setData(ClipboardData(text: textMsg));
        Fluttertoast.showToast(msg: "复制成功");
        break;
      case 2:
        Provider.of<Chat>(context, listen: false)
            .deleteMessages(widget.item!.msgID);
        Fluttertoast.showToast(msg: "删除成功");
        break;
      case 3:
        print("转发");
        break;
      case 4:
        print("撤回");
        Provider.of<Chat>(context, listen: false)
            .revokeMessage(widget.item!.msgID);
        break;
      default:
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
          Column(
            crossAxisAlignment: widget.item!.isSelf == true
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              widget.isGroup == true
                  ? widget.item!.isSelf == true
                      ? Container()
                      : Container(
                          width: 100.w,
                          padding: EdgeInsets.only(
                              left: 15.r, bottom: 10.r, right: 15.r),
                          child: Text(
                            widget.item!.nickName!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.black45, fontSize: 24.sp),
                          ),
                        )
                  : Container(),
              Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: widget.item!.isSelf == true
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  triangle(widget.item!.isSelf),
                  Flexible(
                    child: CustomPopupMenu(
                      child: Container(
                        constraints:
                            BoxConstraints(minHeight: 70.r, minWidth: 70.w),
                        padding: EdgeInsets.all(15.r),
                        decoration: BoxDecoration(
                          color: widget.item!.isSelf == true
                              ? HexColor.fromHex('#9370DB')
                              : Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Text(
                          "$textMsg",
                          style: TextStyle(
                            fontSize: 28.sp,
                          ),
                        ),
                      ),
                      menuBuilder: _buildLongPressMenu,
                      barrierColor: Colors.transparent,
                      pressType: PressType.longPress,
                      verticalMargin: 0,
                      horizontalMargin: 15,
                      controller: _popupMenucontroller,
                    ),
                  ),
                ],
              )
            ],
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

  //长按 弹出菜单
  Widget _buildLongPressMenu() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 180,
        color: const Color(0xFF4C4C4C),
        child: GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          crossAxisCount: 4,
          crossAxisSpacing: 0,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: menuItems
              .map(
                (item) => InkWell(
                  onTap: () {
                    _selectMenu(item.id);
                    _popupMenucontroller.hideMenu();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        item.icon,
                        size: 20,
                        color: Colors.white,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 2),
                        child: Text(
                          item.title,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
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
          ),
        );
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
