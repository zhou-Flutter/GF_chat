import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:video_player/video_player.dart';

class VideoPlay extends StatefulWidget {
  V2TimMessage? videoMessage;
  VideoPlay({
    this.videoMessage,
    Key? key,
  }) : super(key: key);

  @override
  State<VideoPlay> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
  VideoPlayerController? _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.network(widget.videoMessage!.videoElem!.videoUrl!)
          ..initialize().then((_) {
            setState(() {});
          });
    _controller!.play();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            child: _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : Container(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Column(
              children: [
                Container(
                  child: Row(
                    children: [Text("进度条")],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(30.r),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Application.router.pop(context);
                        },
                        child: Container(
                          width: 60.r,
                          height: 60.r,
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Icon(
                            IconData(0xe753, fontFamily: "icons"),
                            color: Colors.white,
                            size: 30.r,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
