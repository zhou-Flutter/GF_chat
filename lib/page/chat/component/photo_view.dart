import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_image.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class PhotosView extends StatefulWidget {
  V2TimMessage? message;
  PhotosView({
    this.message,
    Key? key,
  }) : super(key: key);

  @override
  State<PhotosView> createState() => _PhotosViewState();
}

class _PhotosViewState extends State<PhotosView> {
  V2TimImage? netImg;

  @override
  void initState() {
    super.initState();

    netImg = widget.message!.imageElem!.imageList?.firstWhere(
        (e) => e!.type == V2_TIM_IMAGE_TYPES['ORIGINAL'],
        orElse: () => null);
    setState(() {});
  }

  static const V2_TIM_IMAGE_TYPES = {
    'ORIGINAL': 0,
    'BIG': 1,
    'SMALL': 2,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: PhotoView(
        imageProvider: NetworkImage(netImg!.url!),
      ),
    );
  }
}
