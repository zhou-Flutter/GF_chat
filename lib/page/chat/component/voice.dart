import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/common_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/relative_date_format.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
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
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  Codec _codec = Codec.aacMP4;
  SoundState soundState = SoundState.nosta;

  Timer? _timer;

  Timer? _timer1;

  int duration = 0;

  bool istap = false; //按下状态

  String soundPath = "tau_file.mp4"; //音频文件的位置

  int? path = 0; //音频文件的位置 为了防止重名

  int soundAnim = 0; //录音动画音浪

  @override
  void initState() {
    super.initState();

    openTheRecorder().then((value) {});
  }

  setSoundPathName(sound) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("soundPathName", sound);
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      // _mPath = 'tau_file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        // _mRecorderIsInited = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    // _mRecorderIsInited = true;
  }

  // Future<void> openTheRecorder() async {
  //   var status = await Permission.microphone.request();
  //   if (status != PermissionStatus.granted) {
  //     throw RecordingPermissionException('Microphone permission not granted');
  //   }
  //   await _mRecorder!.openRecorder();

  //   if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
  //     _codec = Codec.opusWebM;
  //     soundPath = 'tau_file.webm';
  //     if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
  //       return;
  //     }
  //   }
  // }

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

  //开始录音
  starSound() async {
    path = Provider.of<Common>(context, listen: false).soundPathName;
    soundPath = "tau_file$path.mp4"; //音频文件的位置
    soundState = SoundState.sound;
    istap = true;
    setState(() {});
    record();
    timer();
  }

  //发送语音
  sendSound(SoundState sound) async {
    await _mRecorder!.stopRecorder().then((value) {
      Provider.of<Common>(context, listen: false).setSoundPathName(path);
      String sendUrl = value!;
      _timer!.cancel();
      switch (sound) {
        case SoundState.sound:
          if (duration < 1) {
            Fluttertoast.showToast(msg: "说话时间太短");
          } else {
            print("发送语音");

            Provider.of<Chat>(context, listen: false).createSoundMsg(
                sendUrl, duration, widget.converID, widget.isGroup);
          }
          break;
        case SoundState.cancel:
          Fluttertoast.showToast(msg: "取消语音发送");
          break;
        case SoundState.text:
          Fluttertoast.showToast(msg: "该版本暂不支持转文字");
          break;
        default:
      }
      duration = 0;
      soundState = SoundState.nosta;
      istap = false;
      setState(() {});
    });
  }

  //开始录制
  void record() {
    _mRecorder!
        .startRecorder(
            toFile: soundPath,
            codec: _codec,
            audioSource: AudioSource.microphone)
        .then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _mRecorder!.closeRecorder();
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
                timer1();
                Vibration.vibrate(duration: 50);
              },
              onTapUp: (e) {
                sendSound(soundState);
                _timer1!.cancel();
                soundAnim = 0;
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

                _timer1!.cancel();
                soundAnim = 0;
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
              soundAnimation(TextDirection.ltr),
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
              soundAnimation(TextDirection.rtl),
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

  //计时器 控制音频喇叭
  timer1() async {
    _timer1 = Timer.periodic(
      const Duration(milliseconds: 600),
      (_timer1) => {
        setState(() {
          soundAnim++;
          if (soundAnim == 4) {
            soundAnim = 1;
          }
        })
      },
    );
  }

  //录音动画
  Widget soundAnimation(TextDirection textDirection) {
    switch (soundAnim) {
      case 0:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: textDirection,
          children: [
            item(Colors.black26),
            item(Colors.black26),
            item(Colors.blue),
          ],
        );
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: textDirection,
          children: [
            item(Colors.black26),
            item(Colors.black26),
            item(Colors.blue),
          ],
        );
      case 2:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: textDirection,
          children: [
            item(Colors.black26),
            item(Colors.blue),
            item(Colors.blue),
          ],
        );
      case 3:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: textDirection,
          children: [
            item(Colors.blue),
            item(Colors.blue),
            item(Colors.blue),
          ],
        );
      default:
        return Container();
    }
  }

  // 录音动画item
  Widget item(Color color) {
    return Container(
      margin: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5.r),
      ),
      height: 15.h,
      width: 5.w,
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
