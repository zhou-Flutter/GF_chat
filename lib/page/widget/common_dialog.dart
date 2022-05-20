import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonDialog extends StatefulWidget {
  String title;
  String subtitle;
  String sure;
  Function clickCallback;
  CommonDialog({
    this.title = "弹窗标题",
    this.subtitle = "副标题",
    this.sure = "确定",
    required this.clickCallback,
    Key? key,
  }) : super(key: key);

  @override
  State<CommonDialog> createState() => _CommonDialogState();
}

class _CommonDialogState extends State<CommonDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          height: 0.5.sw,
          width: 0.75.sw,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40.r),
                child: Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 28.sp,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 80.h,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(width: 1, color: Colors.black12),
                            right: BorderSide(width: 1, color: Colors.black12),
                          ),
                        ),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        widget.clickCallback();
                      },
                      child: Container(
                        height: 80.h,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(width: 1, color: Colors.black12),
                          ),
                        ),
                        child: Text(
                          widget.sure,
                          style: TextStyle(
                            fontSize: 30.sp,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
