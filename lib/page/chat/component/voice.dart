import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/common_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/relative_date_format.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';
import 'package:record/record.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class Voice extends StatefulWidget {
  String converID;
  bool isGroup;
  Voice({
    required this.converID,
    required this.isGroup,
    Key? key,
  }) : super(key: key);

  @override
  State<Voice> createState() => _VoiceState();
}

class _VoiceState extends State<Voice> {
  final record = Record();
  SoundState soundState = SoundState.nosta;

  Timer? _timer;

  Timer? _timer2; //控制音浪计时器

  var soundLv = 0; //音浪等级

  int duration = 0;

  bool istap = false; //按下状态

  @override
  void initState() {
    super.initState();
  }

  //计时器
  void timer() async {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_timer) => {
        setState(() {
          duration++;
        })
      },
    );
  }

  ///音浪计时器 获取音浪大小
  timer2() async {
    _timer2 =
        Timer.periodic(const Duration(milliseconds: 100), (Timer t) async {
      Amplitude? _amplitude = await record.getAmplitude();
      print(" current: ${_amplitude.current}");
      var sound = -(_amplitude.current);
      if (sound > 45) {
        soundLv = 0;
      } else if (45 > sound && sound > 40) {
        soundLv = 1;
      } else if (40 > sound && sound > 35) {
        soundLv = 2;
      } else if (35 > sound && sound > 30) {
        soundLv = 3;
      } else if (30 > sound && sound > 25) {
        soundLv = 4;
      } else if (25 > sound && sound > 20) {
        soundLv = 5;
      } else if (20 > sound && sound > 15) {
        soundLv = 6;
      } else if (15 > sound && sound > 10) {
        soundLv = 7;
      } else if (10 > sound && sound > 5) {
        soundLv = 8;
      } else if (sound < 5) {
        soundLv = 9;
      }
      setState(() {});
    });
  }

  //开始录音
  starSound() async {
    if (await record.hasPermission()) {
      soundState = SoundState.sound;
      istap = true;
      setState(() {});
      timer2();
      timer();
      await record
          .start(
            encoder: AudioEncoder.AAC_LD,
            bitRate: 128000,
            samplingRate: 44100,
          )
          .then((value) {})
          .onError((error, stackTrace) {
        Fluttertoast.showToast(msg: "语音录制出错");
        recoverState();
      });
      ;
    } else {
      Fluttertoast.showToast(msg: "请在设置中授予录音权限");
      recoverState();
    }
  }

  //发送语音
  sendSound(SoundState sound) async {
    bool isRecording = await record.isRecording();
    if (duration > 1) {
      if (isRecording) {
        var path = await record.stop();
        if (path != null) {
          switch (sound) {
            case SoundState.sound:
              Provider.of<Chat>(context, listen: false).createSoundMsg(
                  path, duration, widget.converID, widget.isGroup);
              break;
            case SoundState.cancel:
              Fluttertoast.showToast(msg: "取消语音发送");
              break;
            case SoundState.text:
              Fluttertoast.showToast(msg: "该版本暂不支持转文字");
              break;
            default:
          }
        }
      } else {
        print("没有录制");
      }
    } else {
      Fluttertoast.showToast(msg: "说话时间太短");
    }
    recoverState();
  }

  //恢复录制前的状态
  recoverState() {
    duration = 0;
    soundState = SoundState.nosta;
    istap = false;
    _timer2?.cancel();
    _timer?.cancel();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: HexColor.fromHex('#F7F7F6'),
          border: Border(
            top: BorderSide(
              width: 1.w,
              color: Colors.black12,
            ),
          )),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 50.r),
            child: Column(
              children: [
                istap == true ? soundIng() : soundhand(),
              ],
            ),
          ),
          Positioned(
            child: GestureDetector(
              onTapDown: (e) async {
                starSound();
                Vibration.vibrate(duration: 50);
              },
              onTapUp: (e) {
                print("抬手");
                sendSound(soundState);
              },
              onHorizontalDragUpdate: (e) {
                if (e.localPosition.dx < -43) {
                  soundState = SoundState.text;
                  setState(() {});
                } else if (e.localPosition.dx > 150) {
                  soundState = SoundState.cancel;
                  setState(() {});
                } else {
                  soundState = SoundState.sound;
                  setState(() {});
                }
              },
              onHorizontalDragEnd: (e) {
                sendSound(soundState);
              },
              child: Container(
                height: 180.r,
                width: 180.r,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(50.r),
                  boxShadow: soundState == SoundState.sound
                      ? const [
                          BoxShadow(
                              color: Color(0xFFCE93D8),
                              offset: Offset(-5.0, -5.0)),
                          BoxShadow(
                              color: Color(0xFFCE93D8),
                              offset: Offset(-5.0, 5.0)),
                          BoxShadow(
                              color: Color(0xFFCE93D8),
                              offset: Offset(5.0, -5.0)),
                          BoxShadow(
                              color: Color(0xFFCE93D8),
                              offset: Offset(5.0, 5.0))
                        ]
                      : null,
                ),
                child: Icon(
                  IconData(0xe61c, fontFamily: "icons"),
                  size: 100.sp,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  //录音中
  Widget soundIng() {
    var soundTime = RelativeDateFormat.soundTime(duration);
    return Container(
      padding: EdgeInsets.only(top: 20.r),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              soundView(TextDirection.rtl),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.r),
                child: Text(
                  soundTime,
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 30.sp,
                  ),
                ),
              ),
              soundView(TextDirection.ltr),
            ],
          ),
          Container(
            padding: EdgeInsets.all(50.r),
            child: Row(
              children: [
                Container(
                  width: 120.r,
                  height: 120.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: soundState == SoundState.text
                        ? Colors.blue[400]
                        : HexColor.fromHex('#ECE8E8'),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Icon(
                    IconData(0xe6ec, fontFamily: "icons"),
                    size: 60.sp,
                    color: soundState == SoundState.text
                        ? Colors.white
                        : Colors.black26,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 120.r,
                  height: 120.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: soundState == SoundState.cancel
                        ? Colors.red[400]
                        : HexColor.fromHex('#ECE8E8'),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Icon(
                    IconData(0xe753, fontFamily: "icons"),
                    size: 60.sp,
                    color: soundState == SoundState.cancel
                        ? Colors.white
                        : Colors.black26,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget soundhand() {
    return Container(
      child: Text(
        "按住说话",
        style: TextStyle(
          color: Colors.black45,
          fontSize: 30.sp,
        ),
      ),
    );
  }

  //音浪动画
  Widget soundView(textDirection) {
    List<Widget> list = [];
    for (int i = 0; i <= 9; i++) {
      var item = Container(
        margin: EdgeInsets.all(3),
        height: 18,
        width: 3,
        decoration: BoxDecoration(
          color: soundLv >= i ? Colors.green : Colors.black12,
          borderRadius: BorderRadius.circular(5),
        ),
      );
      list.add(item);
    }
    return Container(
      child: Row(
        textDirection: textDirection,
        children: list,
      ),
    );
  }
}

// 录音状态
enum SoundState {
  nosta, //无状态
  sound, // 录音状态
  cancel, //取消状态
  text, //转文字状态
}
