import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat/config/routes/application.dart';
import 'package:my_chat/config/routes/routes.dart';
import 'package:my_chat/config/style/app_theme.dart';
import 'package:my_chat/provider/chat_provider.dart';
import 'package:my_chat/provider/common_provider.dart';
import 'package:my_chat/provider/init_im_sdk_provider.dart';
import 'package:my_chat/provider/trtc_provider.dart';
import 'package:my_chat/utils/commons.dart';
import 'package:my_chat/utils/locator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tencent_kit/tencent_kit.dart';

const String _TENCENT_APPID = '102005320';
final easyload = EasyLoading.init();
void main() {
  //捕捉flutter异常
  FlutterError.onError = flutterErrorDeetail;

  // 处理dart异常
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    Tencent.instance.setIsPermissionGranted(granted: true);
    Tencent.instance.registerApp(appId: _TENCENT_APPID); //腾讯QQ 登录
    GestureBinding.instance?.resamplingEnabled = true; //重采样 ，是触摸平滑
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    runApp(MyChatApp());
  }, (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

flutterErrorDeetail(FlutterErrorDetails details) async {
  Zone.current.handleUncaughtError(details.exception, details.stack!);
}

Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  print("Flutter端捕获端异常:$error,  异常内容： $stackTrace");
}

class MyChatApp extends StatefulWidget {
  MyChatApp({Key? key}) : super(key: key);

  // 用于路由返回监听
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey(); //全局key

  @override
  State<MyChatApp> createState() => _MyChatAppState();
}

class _MyChatAppState extends State<MyChatApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    //初始化路由配置
    final router = FluroRouter();
    Application.router = router;
    Routes.configureRoutes(router);

    //设置状态栏透明
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(750, 1334),
      builder: () => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => InitIMSDKProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => Chat(),
          ),
          ChangeNotifierProvider(
            create: (_) => Common(),
          ),
          ChangeNotifierProvider(
            create: (_) => Trtc(),
          ),
        ],
        child: RefreshConfiguration(
          headerBuilder: () => Commons.refreshHeader(),
          // 配置默认头部指示器,假如你每个页面的头部指示器都一样的话,你需要设置这个
          footerBuilder: () => Commons.loadingFooter(), // 配置默认底部指示器
          bottomHitBoundary: 100,
          headerTriggerDistance: 80.0, // 头部触发刷新的越界距离
          footerTriggerDistance: 100,
          //  springDescription:SpringDescription(stiffness: 170, damping: 16, mass: 1.9),         // 自定义回弹动画,三个属性值意义请查询flutter api
          maxOverScrollExtent: 100, //头部最大可以拖动的范围,如果发生冲出视图范围区域,请设置这个属性
          maxUnderScrollExtent: 100, // 底部最大可以拖动的范围
          enableScrollWhenRefreshCompleted:
              true, //这个属性不兼容PageView和TabBarView,如果你特别需要TabBarView左右滑动,你需要把它设置为true
          enableLoadingWhenFailed: true, //在加载失败的状态下,用户仍然可以通过手势上拉来触发加载更多
          hideFooterWhenNotFull: false, // Viewport不满一屏时,禁用上拉加载更多功能
          // 当列表无法充满全屏的时候，加载更多跟在列表后面
          shouldFooterFollowWhenNotFull: (status) => false,
          enableBallisticLoad: false, // 可以通过惯性滑动触发加载更多
          child: MaterialApp(
            navigatorKey: MyChatApp.navigatorKey,
            builder: (context, widget) {
              //初始化SDK
              Provider.of<InitIMSDKProvider>(context, listen: false)
                  .initSDK(context);
              Provider.of<Trtc>(context, listen: false).float();

              //加载等待插件
              widget = easyload(context, widget);
              widget = MediaQuery(
                ///设置文字大小不随系统设置改变
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: widget,
              );
              return widget;
            },
            theme: theme,
            title: '肝聊',
            debugShowCheckedModeBanner: false,
            onGenerateRoute: Application.router.generator,
            //国际化，修复默认英语提示复制粘贴等
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
            ],
          ),
        ),
      ),
    );
  }
}
