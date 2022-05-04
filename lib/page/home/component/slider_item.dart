import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/utils/color_tools.dart';
import 'package:my_chat/utils/event_bus.dart';

class SliderItem extends StatefulWidget {
  Function onTap;
  Widget child; //item 布局
  Widget toppingChild; //置顶按钮布局
  Widget deleteChild; //删除按钮布局
  bool isPinned;
  SliderItem({
    Key? key,
    required this.onTap,
    required this.child,
    required this.toppingChild,
    required this.deleteChild,
    this.isPinned = false,
  }) : super(key: key);

  @override
  State<SliderItem> createState() => _SliderItemState();
}

class _SliderItemState extends State<SliderItem>
    with SingleTickerProviderStateMixin {
  double _left = 0.0; //距左边的偏移
  var hideButtonWidth = 130.0; //隐藏的滑块宽度
  var height = 115.h; //滑块高度
  var animatedMilliseconds = 0; //滑块会谈动画时长

  bool isActive = false; //该滑块是否激活
  bool isActivesliderItem = false; //是否有激活的滑块

  Color clickStyle = Colors.white; //点击颜色的变化

  bool taping = false; //控制点击效果

  @override
  void initState() {
    super.initState();
    if (widget.isPinned) {
      clickStyle = HexColor.fromHex('#F5F7FB');
      hideButtonWidth = 160;
      setState(() {});
    }

    //点击关闭滑块
    eventBus.on<SliderIsActiveEvent>().listen((event) {
      topCloseSlider();
    });

    //拖动关闭滑块
    eventBus.on<OnDragSliderItemEvent>().listen((event) {
      onDragCloseSlider();
    });

    //接收是否有滑块激活
    eventBus.on<IsActiveSliderItemEvent>().listen((event) {
      isActivesliderItem = event.isActivesliderItem;
    });
  }

  //通知其他滑块是否有滑块激活
  isActiveEvent(e) {
    eventBus.fire(IsActiveSliderItemEvent(e));
  }

  topCloseSlider() {
    if (isActive) {
      animatedMilliseconds = 200;
      _left = 0;
      isActive = false;
      isActiveEvent(false);
      setState(() {});
    }
  }

  onDragCloseSlider() {
    if (isActive) {
      animatedMilliseconds = 200;
      _left = 0;
      isActive = false;
      setState(() {});
    }
  }

  //拖动关闭滑块
  onDrag() {
    eventBus.fire(OnDragSliderItemEvent(true));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Stack(
        children: <Widget>[
          AnimatedPositioned(
            duration: Duration(milliseconds: animatedMilliseconds),
            left: _left,
            child: GestureDetector(
              child: Row(
                children: [
                  Container(
                    height: height,
                    width: MediaQuery.of(context).size.width,
                    color: taping == false
                        ? clickStyle
                        : HexColor.fromHex('#f5f5f5'),
                    child: widget.child,
                  ),
                  Container(
                    height: height,
                    width: hideButtonWidth,
                    child: Row(
                      children: [
                        widget.toppingChild,
                        widget.deleteChild,
                      ],
                    ),
                  )
                ],
              ),
              onTapDown: (details) {
                setState(() {
                  taping = true;
                });
              },
              onTapCancel: () {
                setState(() {
                  taping = false;
                });
              },
              onTapUp: (e) {
                setState(() {
                  taping = false;
                });
                if (isActivesliderItem) {
                  eventBus.fire(SliderIsActiveEvent(true));
                } else {
                  widget.onTap();
                }
              },
              onHorizontalDragStart: (DragStartDetails details) {
                animatedMilliseconds = 0;

                //当有滑块激活时，滑动本滑块时 先关闭激活的滑块
                if (isActive == false && isActivesliderItem == true) {
                  onDrag();
                }

                setState(() {});
              },
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                //当有别的滑块激活的时候 静止该滑块滑动
                if (isActive == false && isActivesliderItem == true) {
                  print("禁止滑动");
                } else {
                  setState(() {
                    _left += details.delta.dx;
                    //限制向右滑动
                    if (_left > 0) {
                      _left = 0;
                    }
                    //限制向左滑动的距离  防止无限滑动
                    if (_left < -hideButtonWidth) {
                      _left = -hideButtonWidth;
                    }
                  });
                }
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                animatedMilliseconds = 200;

                //当有别的滑块激活时，滑动该滑块时，静止速度惯性激活滑块 并关闭激活的滑块
                if (isActive == false && isActivesliderItem == true) {
                  isActiveEvent(false);
                } else {
                  //如果滑块是激活状态 这无法向左滑动，反之
                  if (!isActive) {
                    if (details.primaryVelocity! < -100) {
                      _left = -hideButtonWidth;
                      isActive = true;
                      isActiveEvent(true);
                    } else {
                      if (_left > -20) {
                        _left = 0;
                        isActive = false;
                        isActiveEvent(false);
                      } else {
                        _left = -hideButtonWidth;
                        isActive = true;
                        isActiveEvent(true);
                      }
                    }
                  } else {
                    if (_left > -hideButtonWidth + 20) {
                      _left = 0;
                      isActive = false;
                      isActiveEvent(false);
                    } else {
                      isActive = true;
                      _left = -hideButtonWidth;
                      isActiveEvent(true);
                    }
                  }
                }
                setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }
}
