import 'package:my_chat/http/request.dart';

class Api {
  //登录
  static Login(data) {
    return Request.post("/login", data: data);
  }
}
