import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/page/widget/avatar.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_image.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class MsgImage extends StatefulWidget {
  V2TimMessage? item;
  MsgImage({
    this.item,
    Key? key,
  }) : super(key: key);

  @override
  State<MsgImage> createState() => _MsgImageState();
}

class _MsgImageState extends State<MsgImage> {
  var imagepath;
  Image? image;
  var imgHeight;
  var imgWidth;
  bool isShowNetImg = false; //是否显示网络图片

  V2TimImage? netImg;
  @override
  void initState() {
    super.initState();
  }

  getImageInfo() {
    imagepath = widget.item!.imageElem!.path;
    File file = File("$imagepath");
    if (!file.existsSync()) {
      isShowNetImg = true;
      getNetImageInfo();
      return null;
    }

    image = Image.file(File(imagepath), fit: BoxFit.fill);
    // 预先获取图片信息
    image!.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      //图片宽高
      var width = info.image.width;
      var height = info.image.height;
      //屏幕宽度
      var pmw = MediaQuery.of(context).size.width;
      //内容宽度
      var conMaxwidth = pmw - 25.w - 70.r - 20.w - 40.r;

      if (width > height) {
        //依赖宽度进行适配
        if (width < 60) {
          //宽度小于80，直接赋值80，高进行比值赋值
          imgWidth = 60;
          imgHeight = 60 / width * height;
        } else {
          // 进行一定比例的缩小
          var bi = 1 - (45 / width);
          imgWidth = 120 * bi;
          imgHeight = imgWidth / width * height;
        }
      } else {
        //依赖高进行适配
        if (height < 60) {
          //高度小于80，直接赋值80，宽进行比值赋值
          imgHeight = 60;
          imgWidth = 60 / height * width;
        } else {
          // 进行一定比例的缩小
          var bi = 1 - (45 / height);
          imgHeight = 120 * bi;
          imgWidth = imgHeight / height * width;
        }
      }
      setState(() {});
    }));
  }

  static const V2_TIM_IMAGE_TYPES = {
    'ORIGINAL': 0,
    'BIG': 1,
    'SMALL': 2,
  };

  getNetImageInfo() {
    netImg = widget.item!.imageElem!.imageList?.firstWhere(
        (e) => e!.type == V2_TIM_IMAGE_TYPES['SMALL'],
        orElse: () => null);
    var width = netImg!.width;
    var height = netImg!.height;
    //屏幕宽度
    var pmw = MediaQuery.of(context).size.width;
    //内容宽度
    var conMaxwidth = pmw - 25.w - 70.r - 20.w - 40.r;
    if (width! > height!) {
      //依赖宽度进行适配
      if (width < 60) {
        //宽度小于80，直接赋值80，高进行比值赋值
        imgWidth = 60;
        imgHeight = 60 / width * height;
      } else {
        // 进行一定比例的缩小
        var bi = 1 - (45 / width);
        imgWidth = 120 * bi;
        imgHeight = imgWidth / width * height;
      }
    } else {
      //依赖高进行适配
      if (height < 60) {
        //高度小于80，直接赋值80，宽进行比值赋值
        imgHeight = 60;
        imgWidth = 60 / height * width;
      } else {
        // 进行一定比例的缩小
        var bi = 1 - (45 / height);
        imgHeight = 120 * bi;
        imgWidth = imgHeight / height * width;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getImageInfo();
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
            width: 25.w,
          ),
          InkWell(
            onTap: () {
              Application.router.navigateTo(
                context,
                "/photosView",
                transition: TransitionType.inFromRight,
                routeSettings: RouteSettings(
                  arguments: {
                    "message": widget.item,
                  },
                ),
              );
            },
            child: isShowNetImg == false
                ? Container(
                    constraints:
                        BoxConstraints(minHeight: 100.r, minWidth: 70.r),
                    width: imgWidth,
                    height: imgHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.r), //弧度
                      child: Image.file(File(imagepath), fit: BoxFit.fill),
                    ),
                  )
                : Container(
                    constraints:
                        BoxConstraints(minHeight: 100.r, minWidth: 70.r),
                    width: imgWidth,
                    height: imgHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.r), //弧度
                      child: Image.network(netImg!.url!, fit: BoxFit.fill),
                    ),
                  ),
          ),
          Container(
            alignment: Alignment.center,
            height: imgHeight,
            width: 70.r,
            child: msgStatus(widget.item!.status),
          ),
          SizedBox(
            width: 20.w,
          ),
        ],
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
        return Container(width: 70.r);
    }
  }
}
