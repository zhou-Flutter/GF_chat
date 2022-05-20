import 'package:fluttertoast/fluttertoast.dart';

class ErrorTips {
  static Map work = {
    30001: "请求参数错误，请根据错误描述检查请求是否正确",
    30539: "等待对方验证中...",
  };

  static errorMsg(error) {
    var txt = work[error];
    Fluttertoast.showToast(msg: txt);
  }
}
