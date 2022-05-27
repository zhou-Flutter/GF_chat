import 'package:flutter/material.dart';
import 'package:my_chat/utils/constant.dart';

class LoginBg extends StatefulWidget {
  LoginBg({Key? key}) : super(key: key);

  @override
  State<LoginBg> createState() => _LoginBgState();
}

class _LoginBgState extends State<LoginBg> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SlideTransition(
          position:
              Tween(begin: const Offset(0, -0.1), end: const Offset(0, -0.4))
                  .chain(CurveTween(curve: Curves.easeInOutCubic))
                  .animate(_animationController!),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 1500,
            color: Colors.black,
            child: Image.asset(
              Constant.assetsImg + "login03.jpg",
              fit: BoxFit.fill,
            ),
          ),
        ),
      ],
    );
  }
}
