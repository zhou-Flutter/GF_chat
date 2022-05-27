import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/commons.dart';

class Search extends StatefulWidget {
  Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with WidgetsBindingObserver {
  //输入框文本控制器
  TextEditingController textEditingController = TextEditingController();

  //控制焦点
  final FocusNode _focusNode = FocusNode();

  //软键盘是否显示
  bool isShow = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SafeArea(
            child: select(),
          ),
          appoint(),
        ],
      ),
    );
  }

  //搜索输入框
  Widget select() {
    return Container(
      padding: EdgeInsets.all(30.r),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10.r),
              height: 60.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HexColor.fromHex("#F3F3F3"),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: TextField(
                controller: textEditingController,
                focusNode: _focusNode,
                autofocus: false,
                decoration: const InputDecoration(
                  hintText: "搜索",
                  hintStyle: TextStyle(
                    color: Colors.black45,
                  ),
                  prefixIcon: Icon(
                    IconData(0xeafe, fontFamily: "icons"),
                    color: Colors.black45,
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 10),
                  filled: false,
                  isCollapsed: true,
                  border: InputBorder.none,
                ),
                onChanged: (e) {
                  // print(e);
                  // inputValue = e;
                  setState(() {});
                },
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Application.router.pop(context);
            },
            child: Container(
              padding: EdgeInsets.only(left: 20.r),
              child: Text(
                "取消",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //指定内容
  Widget appoint() {
    return Container(
      child: Column(
        children: [
          Container(height: 20.h),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(30.r),
            child: Column(
              children: [
                Text(
                  "搜索指定内容",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 25.sp,
                  ),
                ),
                SizedBox(height: 30.r),
                Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Icon(
                            IconData(0xe618, fontFamily: "icons"),
                            color: Colors.black54,
                            size: 50.r,
                          ),
                          SizedBox(height: 20.r),
                          Text(
                            "找人/群",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 25.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Icon(
                            IconData(0xe614, fontFamily: "icons"),
                            color: Colors.black54,
                            size: 50.r,
                          ),
                          SizedBox(height: 20.r),
                          Text(
                            "聊天记录",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 25.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Icon(
                            IconData(0xe7f2, fontFamily: "icons"),
                            color: Colors.black54,
                            size: 50.r,
                          ),
                          SizedBox(height: 20.r),
                          Text(
                            "表情",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 25.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Icon(
                            IconData(0xe611, fontFamily: "icons"),
                            color: Colors.black54,
                            size: 50.r,
                          ),
                          SizedBox(height: 20.r),
                          Text(
                            "群聊",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 25.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
