import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:my_chat/page/widget/avatar.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/constant.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class MsgVoice extends StatefulWidget {
  V2TimMessage? item;
  bool isGroup;
  AudioPlayer? audioPlayer;
  MsgVoice({
    this.item,
    this.audioPlayer,
    required this.isGroup,
    Key? key,
  }) : super(key: key);

  @override
  State<MsgVoice> createState() => _MsgVoiceState();
}

class _MsgVoiceState extends State<MsgVoice> {
  var time = 0; //音频时长

  Timer? _timer; // 计时器

  int palyImg = 0; //用来控制播放音频时 显示的图片

  bool isPlay = false;
  bool ishowUnreadReddot = false;

  @override
  void initState() {
    super.initState();

    widget.audioPlayer!.onPlayerStateChanged.listen((PlayerState e) {
      if (mounted) {
        switch (e) {
          case PlayerState.PLAYING:
            print("播放中");

            break;
          case PlayerState.COMPLETED:
            print("播放完成");
            if (_timer != null) {
              _timer!.cancel();
            }
            palyImg = 0;
            isPlay = false;
            break;
          case PlayerState.STOPPED:
            print("播放停止");
            if (_timer != null) {
              _timer!.cancel();
            }
            palyImg = 0;
            isPlay = false;

            break;
          case PlayerState.PAUSED:
            print("播放暂停");
            break;
          default:
        }
        setState(() {});
      }
    });

    time = widget.item!.soundElem!.duration!;

    //控制语音未读红点
    if (widget.item!.localCustomInt == 0) {
      ishowUnreadReddot = true;
      setState(() {});
    }
  }

  //播放音频
  play() async {
    print(isPlay);
    if (isPlay) {
      stopPlayer();
    } else {
      await widget.audioPlayer!.stop();
      if (widget.item!.soundElem!.url != null) {
        var soundurl = widget.item!.soundElem!.url!;
        await widget.audioPlayer!.play(soundurl);
        isPlay = true;
        timer();
      } else {
        Fluttertoast.showToast(msg: "音频出现错误");
      }
    }
  }

  //按钮触发 音频 stop
  void stopPlayer() async {
    await widget.audioPlayer!.stop();
    if (_timer != null) {
      _timer!.cancel();
    }
    palyImg = 0;
    isPlay = false;
    setState(() {});
  }

  //计时器 控制音频喇叭
  timer() async {
    _timer = Timer.periodic(
      const Duration(milliseconds: 600),
      (_timer) => {
        setState(() {
          palyImg++;
          if (palyImg == 4) {
            palyImg = 1;
          }
        })
      },
    );
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    child: InkWell(
                      onTap: () {
                        //未读语音
                        if (ishowUnreadReddot == true) {
                          ishowUnreadReddot = false;
                          Provider.of<Chat>(context, listen: false)
                              .setLocalCustomInt(widget.item!.msgID, 1);
                        }
                        play();
                      },
                      child: Container(
                        constraints:
                            BoxConstraints(minHeight: 70.r, minWidth: 70.w),
                        padding: EdgeInsets.only(
                            top: 10.r, right: 10.r, bottom: 10.r),
                        decoration: BoxDecoration(
                          color: widget.item!.isSelf == true
                              ? HexColor.fromHex('#9370DB')
                              : Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Container(
                          width: 140.r,
                          child: Row(
                            textDirection: widget.item!.isSelf == true
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            children: [
                              Container(
                                height: 50.r,
                                width: 50.r,
                                child: Directionality(
                                  textDirection: widget.item!.isSelf == true
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  child: playAnimation(),
                                ),
                              ),
                              SizedBox(width: 15.w),
                              Text(
                                "$time\"",
                                style: TextStyle(
                                  fontSize: 30.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  unreadRedDot(),
                ],
              )
            ],
          ),
          SizedBox(
            width: 20.h,
          ),
        ],
      ),
    );
  }

  //语音 未读红点
  Widget unreadRedDot() {
    return Container(
      alignment: Alignment.center,
      height: 70.r,
      width: 40.r,
      child: widget.item!.isSelf == true
          ? msgStatus(widget.item!.status)
          : ishowUnreadReddot == true
              ? Container(
                  child: Icon(
                    Icons.fiber_manual_record,
                    color: Colors.red,
                    size: 15.sp,
                  ),
                )
              : Container(),
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

  //播放语音动画
  Widget playAnimation() {
    switch (palyImg) {
      case 0:
        return Image.asset(
          "assets/imgs/chat/left_voice_3.png",
          matchTextDirection: true,
        );
      case 1:
        return Image.asset(
          "assets/imgs/chat/left_voice_1.png",
          matchTextDirection: true,
        );
      case 2:
        return Image.asset(
          "assets/imgs/chat/left_voice_2.png",
          matchTextDirection: true,
        );
      case 3:
        return Image.asset(
          "assets/imgs/chat/left_voice_3.png",
          matchTextDirection: true,
        );
      default:
        return Container();
    }
  }
}
