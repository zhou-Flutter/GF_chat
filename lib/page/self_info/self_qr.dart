import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/friend_provider.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

class SelfQr extends StatefulWidget {
  SelfQr({Key? key}) : super(key: key);

  @override
  State<SelfQr> createState() => _SelfQrState();
}

class _SelfQrState extends State<SelfQr> {
  GlobalKey repaintKey = GlobalKey();

  List<V2TimUserFullInfo> selfInfo = [];
  V2TimUserFullInfo? info;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selfInfo = Provider.of<Friend>(context, listen: false).selfInfo;
    if (selfInfo.isNotEmpty) {
      info = selfInfo[0];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backBtn(context),
        title: Text(
          "二维码名片",
          style: TextStyle(fontSize: 30.sp),
        ),
      ),
      body: Center(
        child: Container(
          width: 600.w,
          height: 600.h,
          decoration: BoxDecoration(
              color: Colors.black12, borderRadius: BorderRadius.circular(15.r)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: repaintKey,
                child: Container(
                  child: QrImage(
                    data: '${info!.userID}',
                    version: QrVersions.auto,
                    size: 400.r,
                    gapless: false,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  print("保存二维码");
                  _save(repaintKey);
                },
                child: Container(
                  child: Text(
                    "扫一扫或保存二维码，和我聊天",
                    style: TextStyle(
                      color: Colors.black26,
                      fontSize: 30.sp,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void saveQrcodeImage() async {
    EasyLoading.show(status: '正在保存...');
    RenderRepaintBoundary? boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
    boundary!.toImage().then((value) async {
      ByteData? byteData =
          await value.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      Permission filePermission = Permission.storage;
      var status = await filePermission.status;
      if (!status.isGranted) {
        Map<Permission, PermissionStatus> statuses =
            await [filePermission].request();
        saveQrcodeImage();
      }
      if (status.isGranted) {
        final result = await ImageGallerySaver.saveImage(pngBytes, quality: 80);
        print(result.toString());
        if (result["isSuccess"]) {
          EasyLoading.dismiss();
          print('图片保存 ok');
        } else {
          print('图片保存 error');
        }
      }
      if (status.isDenied) {
        print("拒绝访问照片文件");
      }
    });
  }

  void _save(globalKey) async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List picBytes = byteData!.buffer.asUint8List();
    final result = await ImageGallerySaver.saveImage(picBytes,
        quality: 100, name: "hello");
    print(result);
    if (result['isSuccess']) {
      EasyLoading.showToast('保存成功');
    } else {
      EasyLoading.showToast('保存失败');
    }
  }
}
