import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/constant.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart'
    as refresh;

class Commons {
  //下拉刷新的头部
  static refreshHeader() {
    return refresh.ClassicHeader(
      textStyle: TextStyle(fontSize: 24.sp),
      refreshingIcon: SizedBox(
        width: 16.0,
        height: 16.0,
        child: defaultTargetPlatform == TargetPlatform.iOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Colors.grey,
              ),
      ),
      height: 45.0,
      releaseText: '松开手刷新',
      refreshingText: '刷新中',
      completeText: '刷新完成',
      failedText: '刷新失败',
      idleText: '下拉刷新',
    );
  }

  //下载更多的头部
  static loadingFooter() {
    return refresh.ClassicFooter(
      textStyle: TextStyle(fontSize: 24.sp, color: Colors.black45),
      loadingIcon: SizedBox(
        width: 16.0,
        height: 16.0,
        child: defaultTargetPlatform == TargetPlatform.iOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Colors.grey,
              ),
      ),
      height: 45.0,
      canLoadingText: '松开手加载',
      failedText: '加载失败',
      idleText: '上拉加载',
      loadingText: '加载中',
      noDataText: '已经到底了~',
    );
  }

  static customFooter() {
    return CustomFooter(
      enableInfiniteLoad: false,
      extent: 40.0,
      triggerDistance: 40.0,
      footerBuilder: (context,
          loadState,
          pulledExtent,
          loadTriggerPullDistance,
          loadIndicatorExtent,
          axisDirection,
          float,
          completeDuration,
          enableInfiniteLoad,
          success,
          noMore) {
        return Stack(
          children: <Widget>[
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                height: 30.0,
                padding: EdgeInsets.symmetric(horizontal: 330.r),
                child: LoadingIndicator(
                  indicatorType: Indicator.ballPulse,
                  colors: [
                    HexColor.fromHex('#9370DB'),
                    HexColor.fromHex('#6495ED'),
                    HexColor.fromHex('#FFDEAD'),
                  ],
                  strokeWidth: 3,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

//禁止多点触控
class SingleTouchRecognizerWidget extends StatelessWidget {
  final Widget? child;
  SingleTouchRecognizerWidget({this.child});

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        _SingleTouchRecognizer:
            GestureRecognizerFactoryWithHandlers<_SingleTouchRecognizer>(
          () => _SingleTouchRecognizer(),
          (_SingleTouchRecognizer instance) {},
        ),
      },
      child: child,
    );
  }
}

class _SingleTouchRecognizer extends OneSequenceGestureRecognizer {
  int _p = 0;
  @override
  void addAllowedPointer(PointerDownEvent event) {
    //first register the current pointer so that related events will be handled by this recognizer
    startTrackingPointer(event.pointer);
    //ignore event if another event is already in progress
    if (_p == 0) {
      resolve(GestureDisposition.rejected);
      _p = event.pointer;
    } else {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  // TODO: implement debugDescription
  String get debugDescription => throw UnimplementedError();

  @override
  void didStopTrackingLastPointer(int pointer) {
    // TODO: implement didStopTrackingLastPointer
  }

  @override
  void handleEvent(PointerEvent event) {
    if (!event.down && event.pointer == _p) {
      _p = 0;
    }
  }
}

//返回按钮
Widget backBtn(context) {
  return Container(
    child: IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        size: 40.r,
        color: Colors.black,
      ),
      onPressed: () {
        Application.router.pop(context);
      },
    ),
  );
}

//自定义点击效果
class CustomTap extends StatefulWidget {
  Function onTap;
  Widget child;
  Color bgColor;
  Color tapColor;
  double radius;
  CustomTap({
    required this.onTap,
    required this.child,
    this.bgColor = Colors.white,
    required this.tapColor,
    this.radius = 0.0,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomTap> createState() => _CustomTapState();
}

class _CustomTapState extends State<CustomTap> {
  bool taping = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          taping = true;
        });
      },
      onTapUp: (e) {
        setState(() {
          taping = false;
        });
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          taping = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: taping == false ? widget.bgColor : widget.tapColor,
        ),
        child: widget.child,
      ),
    );
  }
}
