import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:images_picker/images_picker.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/init_im_sdk_provider.dart';
import 'package:my_chat/provider/trtc_provider.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class FileMenu extends StatefulWidget {
  String converID;
  bool isGroup;

  FileMenu({
    required this.converID,
    required this.isGroup,
    Key? key,
  }) : super(key: key);

  @override
  State<FileMenu> createState() => _FileMenuState();
}

class _FileMenuState extends State<FileMenu> {
  List fileMenu = [
    {"id": 0, "icon": 0xe7f1, "name": "相册"},
    {"id": 1, "icon": 0xe61e, "name": "拍摄"},
    {"id": 2, "icon": 0xe607, "name": "视频"},
    {"id": 3, "icon": 0xe963, "name": "语音通话"},
    {"id": 4, "icon": 0xe677, "name": "视频通话"},
    {"id": 5, "icon": 0xe60e, "name": "红包"},
    {"id": 6, "icon": 0xeac4, "name": "文件"},
  ];
  var imageSize = 20 * 1024; //发送图片不能超过20M

  var selfId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selfId = Provider.of<InitIMSDKProvider>(context, listen: false).selfId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 40.r, horizontal: 20.r),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: HexColor.fromHex('#F7F7F6'),
          border: Border(
            top: BorderSide(
              width: 1.w,
              color: Colors.black12,
            ),
          )),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, //横轴三个子widget
            childAspectRatio: 1.0 //宽高比为1时，子widget
            ),
        itemCount: fileMenu.length,
        itemBuilder: (BuildContext context, int index) {
          return FileItem(fileMenu[index]);
        },
      ),
    );
  }

  //文件菜单 item
  Widget FileItem(item) {
    return Column(
      children: [
        CustomTap(
          onTap: () {
            select(item["id"]);
          },
          tapColor: Colors.black12,
          radius: 10.r,
          child: Container(
            padding: EdgeInsets.all(25.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(
              IconData(item["icon"], fontFamily: "icons"),
              size: 45.sp,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(5.r),
          child: Text(
            item["name"],
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.black45,
            ),
          ),
        )
      ],
    );
  }

  select(id) {
    switch (id) {
      case 0:
        getImage();
        break;
      case 1:
        getCamera();
        break;
      case 2:
        getVideo();
        break;
      case 3:
        voiceCall();
        break;
      case 4:
        Fluttertoast.showToast(msg: "视频通话还在开发中");
        break;
      case 5:
        Fluttertoast.showToast(msg: "红包还在开发中");
        break;
      default:
        Fluttertoast.showToast(msg: "功能还在开发中");
    }
  }

  //相册发送图片
  Future getImage() async {
    List<Media>? res = await ImagesPicker.pick(
      count: 3,
      pickType: PickType.image,
    );
    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        if (imageSize > res[i].size) {
          print(res[i].path);
          Provider.of<Chat>(context, listen: false)
              .sendImageMsg(res[i].path, widget.converID, widget.isGroup);
        } else {
          Fluttertoast.showToast(msg: "图片太大，无法发送");
        }
      }
    }
  }

  //拍照发送图片
  Future getCamera() async {
    List<Media>? res = await ImagesPicker.openCamera(
      pickType: PickType.image, // 拍摄视频
    );
    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        if (imageSize > res[i].size) {
          print(res[i].path);
          Provider.of<Chat>(context, listen: false)
              .sendImageMsg(res[i].path, widget.converID, widget.isGroup);
        } else {
          Fluttertoast.showToast(msg: "图片太大，无法发送");
        }
      }
    }
  }

  //选择视频发送
  Future getVideo() async {
    VideoPlayerController controller;
    int seconds = 0;
    List<Media>? res = await ImagesPicker.pick(
      count: 1,
      pickType: PickType.video,
    );
    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        if (imageSize > res[i].size) {
          print(res[i].path);
          controller = VideoPlayerController.file(File(res[i].path));
          controller.initialize().then((value) {
            seconds = controller.value.duration.inSeconds;

            Provider.of<Chat>(context, listen: false).sendVideoMsg(
                res[i].path,
                "mp4",
                seconds,
                res[i].thumbPath!,
                widget.converID,
                widget.isGroup);
          });
        } else {
          Fluttertoast.showToast(msg: "视频太大，无法发送");
        }
      }
    }
  }

  //语音童话
  Future voiceCall() async {
    CallStatus callStatus =
        Provider.of<Trtc>(context, listen: false).callStatus;
    if (callStatus != CallStatus.nocall) {
      Fluttertoast.showToast(msg: "已在通话中。。。");
    } else {
      Provider.of<Trtc>(context, listen: false)
          .enterRoom(widget.converID, selfId);
    }
  }
}
