import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';

//群聊头像
class GroupAvatar extends StatefulWidget {
  double size;
  List<V2TimGroupMemberFullInfo?> groupMemberList;

  GroupAvatar({
    Key? key,
    required this.size,
    required this.groupMemberList,
  }) : super(key: key);

  @override
  State<GroupAvatar> createState() => _GroupAvatarState();
}

class _GroupAvatarState extends State<GroupAvatar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size,
      width: widget.size,
      padding: EdgeInsets.all(7.r),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemCount: widget.groupMemberList.length,
          itemBuilder: (context, index) {
            return Container(
              child: CachedNetworkImage(
                imageUrl: widget.groupMemberList[index]!.faceUrl!,
                placeholder: (context, url) => defaultHeadPic(),
                errorWidget: (context, url, error) => defaultHeadPic(),
                fit: BoxFit.fill,
              ),
            );
          }),
    );
  }

  //默认显示头像
  Widget defaultHeadPic() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black12,
      ),
    );
  }
}
