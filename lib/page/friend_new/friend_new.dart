import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/utils/constant.dart';

class FriendNewPage extends StatefulWidget {
  const FriendNewPage({Key? key}) : super(key: key);

  @override
  State<FriendNewPage> createState() => _FriendNewPageState();
}

class _FriendNewPageState extends State<FriendNewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            Constant.assetsImg + 'back_blc.png',
            width: 40.w,
          ),
          onPressed: () {
            Application.router.pop(context);
          },
        ),
        centerTitle: true,
        title: Text("新的朋友"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
