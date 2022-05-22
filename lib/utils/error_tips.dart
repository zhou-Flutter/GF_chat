import 'package:fluttertoast/fluttertoast.dart';

class ErrorTips {
  static Map work = {
    7005: "文件大小超出了限制，如果上传文件，最大限制是100MB",
    7013: "套餐包不支持该接口的使用，请升级到旗舰版套餐",
    7014: "非法请求",
    30001: "请求参数错误，请根据错误描述检查请求是否正确",
    30539: "等待对方验证中...",
  };

  static errorMsg(error) {
    var txt = work[error];
    if (txt != null) {
      Fluttertoast.showToast(msg: txt);
    } else {
      Fluttertoast.showToast(msg: "错误");
    }
  }
}
