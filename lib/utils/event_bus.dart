import 'package:event_bus/event_bus.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

EventBus eventBus = new EventBus();

//好友列表滑块
class SliderIsActiveEvent {
  bool isactive;
  SliderIsActiveEvent(this.isactive);
}

class IsActiveSliderItemEvent {
  bool isActivesliderItem;
  IsActiveSliderItemEvent(this.isActivesliderItem);
}

class OnDragSliderItemEvent {
  bool isActiveslider;
  OnDragSliderItemEvent(this.isActiveslider);
}

//点击空白关闭底部键盘
class CloseButtonKeyEvent {
  bool close;
  CloseButtonKeyEvent(this.close);
}

//展示发生时的加载或者失败提示
class IsShowSendingIconEvent {
  String? id;
  double? height;
  IsShowSendingIconEvent(this.id, this.height);
}

//刷新聊天页面
class UpdateChatPageEvent {
  bool isAm;
  List<V2TimMessage> c2CMsgList;
  UpdateChatPageEvent(this.c2CMsgList, this.isAm);
}

//刷新 群聊 聊天页面
class UpdateGroupChatPageEvent {
  List<V2TimMessage> groupMsgList;
  UpdateGroupChatPageEvent(this.groupMsgList);
}

//聊天页面可展示的高度
class ChatPageHightEvent {
  double hight;
  ChatPageHightEvent(this.hight);
}

//聊天页面消息的总高度
class ChatMsgHightEvent {
  double hight;
  ChatMsgHightEvent(this.hight);
}

//通知 界面
class NoticeEvent {
  Notice notice;
  NoticeEvent(this.notice);
}

enum Notice {
  voicePage, //通话界面
}
