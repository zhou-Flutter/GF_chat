import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/page/chat/component/emoticon.dart';
import 'package:my_chat/page/chat/component/file_menu.dart';
import 'package:my_chat/page/chat/component/voice.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/event_bus.dart';

import 'package:provider/provider.dart';
import 'package:text_span_field/text_span_builder.dart';
import 'package:text_span_field/text_span_field.dart';

late StreamSubscription<bool> keyboardSubscription;

class ButtonInputBox extends StatefulWidget {
  var userID;
  var animatedListKey;
  ButtonInputBox({
    this.userID,
    this.animatedListKey,
    Key? key,
  }) : super(key: key);

  @override
  State<ButtonInputBox> createState() => _ButtonInputBoxState();
}

class _ButtonInputBoxState extends State<ButtonInputBox>
    with
        WidgetsBindingObserver,
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin {
  @protected
  bool get wantKeepAlive => true; //保持页面 tab

  //输入框文本控制器
  TextEditingController textEditingController = TextEditingController();

  // final MySpecialTextSpanBuilder _mySpecialTextSpanBuilder =
  //     MySpecialTextSpanBuilder(showAtBackground: true);

  TextSpanBuilder textSpanBuilder = TextSpanBuilder();

  // final MyTextSelectionControls _myExtendedMaterialTextSelectionControls =
  //     MyTextSelectionControls();

  final FocusNode _focusNode = FocusNode();

  final GlobalKey _key = GlobalKey();

  BtnMeuType btnMeuType = BtnMeuType.key; //底部发送菜单的类型
  var keyboardHight = 0.0; //底部表情菜单的高

  var saveKeyboardHight = 450.h; //存储实际键盘高度

  var inputContent = ""; //输入框输入的类容

  bool istop = false; //判断是否点击的是键盘自带的关闭按钮 来关闭键盘

  int _currentTopTabIndex = 0; //表情包 tab

  bool isKeyboardActived = false; // 当前键盘是否是激活状态

  var chatpageHight; //聊天页面的高度

  var chatMsgHight; //所有消息高度

  List fileMenu = [
    {"id": 0, "icon": 0xe7f1, "name": "相册", "type": "xc"},
    {"id": 1, "icon": 0xe61e, "name": "拍摄", "type": "pz"},
    {"id": 2, "icon": 0xe693, "name": "视频", "type": "sp"},
    {"id": 3, "icon": 0xe7e6, "name": "位置", "type": "wz"},
    {"id": 4, "icon": 0xe60e, "name": "红包", "type": "hb"},
    {"id": 5, "icon": 0xe61c, "name": "语音", "type": "yy"},
    {"id": 6, "icon": 0xeac4, "name": "文件", "type": "wj"},
  ];

  @override
  void initState() {
    super.initState();

    //初始化 监听
    WidgetsBinding.instance!.addObserver(this);

    //关闭键盘
    eventBus.on<CloseButtonKeyEvent>().listen((event) {
      if (mounted) {
        closeButtonKey();
      }
    });

    // //聊天页面的高
    // eventBus.on<ChatPageHightEvent>().listen((event) {
    //   chatpageHight = event.hight;
    // });

    // 消息的高
    // eventBus.on<ChatMsgHightEvent>().listen((event) {
    //   chatMsgHight = event.hight;
    // });

    textEditingController.addListener(() {
      inputContent = textEditingController.text;

      setState(() {});
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    WidgetsBinding.instance!.addPostFrameCallback((de) {
      setState(() {
        if (MediaQuery.of(context).viewInsets.bottom < 30) {
          //关闭键盘
          if (!istop) {
            keyboardHight = 0;
          }
          istop = false;
          isKeyboardActived = false;
        } else {
          //显示键盘
          isKeyboardActived = true;
          istop = false;
          btnMeuType = BtnMeuType.key;
          keyboardHight = MediaQuery.of(context).viewInsets.bottom;
          saveKeyboardHight = MediaQuery.of(context).viewInsets.bottom;
          print("监听");
          print(MediaQuery.of(context).viewInsets.bottom);
        }
      });
    });
  }

  @override
  void dispose() {
    // keyboardSubscription.cancel();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  //点击空白出 关闭底部所有键盘 表情包菜单
  closeButtonKey() async {
    keyboardHight = 0;
    btnMeuType = BtnMeuType.key;
    // FocusScope.of(context).unfocus();
    closekey();
    setState(() {});
  }

  //关闭键盘
  closekey() {
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 15.r),
          decoration: BoxDecoration(
            color: HexColor.fromHex('#F7F7F6'),
            border: Border(
              top: BorderSide(
                width: 1.r,
                color: Colors.black12,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 5.r),
                child: InkWell(
                  onTap: () async {
                    istop = true;
                    if (btnMeuType != BtnMeuType.voice) {
                      btnMeuType = BtnMeuType.voice;
                      closekey();
                      keyboardHight = saveKeyboardHight;
                    } else {
                      btnMeuType = BtnMeuType.key;
                      SystemChannels.textInput
                          .invokeMethod<void>('TextInput.show');
                      FocusScope.of(context).requestFocus(_focusNode);
                    }
                    setState(() {});
                  },
                  child: btnMeuType == BtnMeuType.voice
                      ? Icon(
                          const IconData(0xe661, fontFamily: "icons"),
                          size: 55.sp,
                        )
                      : Icon(
                          const IconData(0xe66c, fontFamily: "icons"),
                          size: 55.sp,
                        ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding:
                      EdgeInsets.symmetric(vertical: 15.r, horizontal: 15.r),
                  margin: EdgeInsets.symmetric(horizontal: 20.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: TextSpanField(
                    key: _key,
                    textSpanBuilder: textSpanBuilder,
                    // specialTextSpanBuilder: _mySpecialTextSpanBuilder,
                    controller: textEditingController,
                    focusNode: _focusNode,
                    autofocus: false,
                    autocorrect: true,
                    maxLines: 4,
                    minLines: 1,
                    style: TextStyle(
                      fontSize: 30.sp,
                    ),
                    decoration: const InputDecoration(
                      filled: false,
                      isCollapsed: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  istop = true;
                  if (btnMeuType != BtnMeuType.emo) {
                    //显示表情菜单
                    btnMeuType = BtnMeuType.emo;
                    closekey();
                    keyboardHight = saveKeyboardHight;
                  } else {
                    btnMeuType = BtnMeuType.key;
                    SystemChannels.textInput
                        .invokeMethod<void>('TextInput.show');
                    FocusScope.of(context).requestFocus(_focusNode);
                  }
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.only(bottom: 7.r),
                  child: btnMeuType == BtnMeuType.emo
                      ? Icon(
                          const IconData(0xe661, fontFamily: "icons"),
                          size: 50.sp,
                        )
                      : Icon(
                          const IconData(0xe60b, fontFamily: "icons"),
                          size: 50.sp,
                        ),
                ),
              ),
              textEditingController.text != ""
                  ? InkWell(
                      onTap: () {
                        // print("发送");
                        // bool isAm = false;
                        // if (isKeyboardActived) {
                        //   if (chatpageHight - saveKeyboardHight >
                        //       chatMsgHight) {
                        //     //没有动画
                        //     isAm = false;
                        //   } else {
                        //     //有动画
                        //     isAm = true;
                        //   }
                        // } else {
                        //   if (chatpageHight > chatMsgHight) {
                        //     //没有动画
                        //     isAm = false;
                        //   } else {
                        //     //有动画
                        //     isAm = true;
                        //   }
                        // }

                        Provider.of<Chat>(context, listen: false)
                            .sendTextMsg(inputContent, widget.userID, false);
                        textEditingController.clear();

                        setState(() {});
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 50.h,
                        width: 100.w,
                        margin: EdgeInsets.only(bottom: 5.r, left: 20.r),
                        decoration: BoxDecoration(
                          color: Colors.green[400],
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          "发送",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        istop = true;
                        if (btnMeuType != BtnMeuType.file) {
                          //显示文件菜单
                          btnMeuType = BtnMeuType.file;
                          keyboardHight = saveKeyboardHight;
                          closekey();
                          FocusScope.of(context).requestFocus(FocusNode());
                        } else {
                          btnMeuType = BtnMeuType.key;
                          SystemChannels.textInput
                              .invokeMethod<void>('TextInput.show');
                          FocusScope.of(context).requestFocus(_focusNode);
                        }
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.only(bottom: 7.r, left: 20.r),
                        child: Icon(
                          const IconData(0xe657, fontFamily: "icons"),
                          size: 48.sp,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        InkWell(
          onTap: () {},
          child: Container(
            height: keyboardHight,
            width: MediaQuery.of(context).size.width,
            color: HexColor.fromHex('#F7F7F6'),
            child: EmoFile(btnMeuType),
          ),
        ),
      ],
    );
  }

  Widget EmoFile(BtnMeuType btnMeuType) {
    return Stack(
      children: [
        Container(),
        Positioned(
          child: Visibility(
            visible: btnMeuType == BtnMeuType.emo ? true : false,
            maintainState: true,
            child: EmoTicon(
              textSpanBuilder: textSpanBuilder,
              userID: widget.userID,
            ),
          ),
        ),
        Positioned(
          child: Visibility(
            visible: btnMeuType == BtnMeuType.file ? true : false,
            maintainState: true,
            child: FileMenu(
              userID: widget.userID,
            ),
          ),
        ),
        Positioned(
          child: Visibility(
            visible: btnMeuType == BtnMeuType.voice ? true : false,
            maintainState: false,
            child: Voice(
              userID: widget.userID,
            ),
          ),
        )
      ],
    );

    // switch (btnMeuType) {
    //   case BtnMeuType.key:
    //     return Container();
    //     break;
    //   case BtnMeuType.emo:
    //     return EmoTicon(textSpanBuilder: textSpanBuilder);
    //     break;
    //   case BtnMeuType.file:
    //     return FileMenu();
    //     break;
    //   case BtnMeuType.voice:
    //     return Voice();
    //     break;
    //   default:
    //     return Container();
    // }
  }
}

//底部表情文件菜单类型
enum BtnMeuType {
  voice, //语音
  key, //键盘
  emo, //表情包
  file, //文件
}
