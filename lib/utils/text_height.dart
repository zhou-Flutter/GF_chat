import 'package:flutter/material.dart';

class TextHegiht {
//获取文本消息的高
  static double calculateTextHeight(
      {required BuildContext context,
      required String value,
      fontSize,
      FontWeight? fontWeight,
      required double maxWidth,
      int? maxLines}) {
    value = filterText(value);
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    TextPainter painter = TextPainter(
      ///AUTO：华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
      locale: WidgetsBinding.instance!.window.locale,
      textDirection: TextDirection.ltr,
      textScaleFactor: textScaleFactor, //字体缩放大小
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontSize: fontSize,
        ),
      ),
    );
    painter.layout(maxWidth: maxWidth);

    ///文字的宽度:painter.width
    return painter.height;
  }

  static String filterText(String text) {
    String tag = '<br>';
    while (text.contains('<br>')) {
      // flutter 算高度,单个\n算不准,必须加两个
      text = text.replaceAll(tag, '\n\n');
    }
    return text;
  }
}
