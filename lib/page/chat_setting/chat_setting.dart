import 'package:flutter/material.dart';
import 'package:my_chat/utils/commons.dart';

class ChatSetting extends StatefulWidget {
  const ChatSetting({Key? key}) : super(key: key);

  @override
  State<ChatSetting> createState() => _ChatSettingState();
}

class _ChatSettingState extends State<ChatSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backBtn(context),
        title: Text("聊天设置"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
