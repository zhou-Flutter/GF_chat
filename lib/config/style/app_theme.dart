import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final ThemeData theme = ThemeData(
  primaryColor: Colors.white,
  splashColor: Colors.transparent, // 取消水波纹效果
  highlightColor: Colors.transparent,

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 36.sp,
      fontWeight: FontWeight.w500,
    ),
  ),
);
