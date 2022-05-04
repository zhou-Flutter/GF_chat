import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:provider/provider.dart';

class Avatar extends StatelessWidget {
  bool isSelf;
  var faceUrl;
  double size;
  Avatar({
    required this.isSelf,
    this.faceUrl,
    required this.size,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var faceUrlMe =
        Provider.of<Chat>(context, listen: false).selfInfo[0].faceUrl;
    return Container(
      child: isSelf == true
          ? Container(
              child: faceUrlMe == null || faceUrlMe == ""
                  ? defaultHeadPic()
                  : Container(
                      height: size,
                      width: size,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.r), //弧度
                        child: CachedNetworkImage(
                          imageUrl: faceUrlMe,
                          placeholder: (context, url) => defaultHeadPic(),
                          errorWidget: (context, url, error) =>
                              defaultHeadPic(),
                          fit: BoxFit.fill,
                        ),

                        // Image.network(
                        //   faceUrlMe, //图片路径
                        //   fit: BoxFit.fill,
                        // ),
                      ),
                    ),
            )
          : Container(
              child: faceUrl == null || faceUrl == ""
                  ? defaultHeadPic()
                  : Container(
                      height: size,
                      width: size,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.r), //弧度
                        child: CachedNetworkImage(
                          imageUrl: faceUrl,
                          placeholder: (context, url) => defaultHeadPic(),
                          errorWidget: (context, url, error) =>
                              defaultHeadPic(),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
            ),
    );
  }

  //默认显示头像
  Widget defaultHeadPic() {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15.r),
      ),
    );
  }
}
