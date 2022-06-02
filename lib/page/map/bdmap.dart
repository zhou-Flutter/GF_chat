// import 'dart:io';
// import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
//     show BMFMapSDK, BMF_COORD_TYPE;
// import 'package:flutter/material.dart';
// import 'package:flutter_bmflocation/flutter_bmflocation.dart';
// import 'package:my_chat/page/map/singleLocationPage.dart';
// import 'package:permission_handler/permission_handler.dart';

// class BdMap extends StatefulWidget {
//   BdMap({Key? key}) : super(key: key);

//   @override
//   State<BdMap> createState() => _BdMapState();
// }

// class _BdMapState extends State<BdMap> {
//   @override
//   void initState() {
//     super.initState();

//     LocationFlutterPlugin myLocPlugin = LocationFlutterPlugin();

//     /// 动态申请定位权限
//     requestPermission();
//     // 设置是否隐私政策
//     myLocPlugin.setAgreePrivacy(true);
//     BMFMapSDK.setAgreePrivacy(true);

//     if (Platform.isIOS) {
//       /// 设置ios端ak, android端ak可以直接在清单文件中配置
//       myLocPlugin.authAK('请 输 入 您 的 AK');
//       BMFMapSDK.setApiKeyAndCoordType('请 输 入 您 的 AK', BMF_COORD_TYPE.BD09LL);
//     } else if (Platform.isAndroid) {
//       // Android 目前不支持接口设置Apikey,
//       // 请在主工程的Manifest文件里设置，详细配置方法请参考官网(https://lbsyun.baidu.com/)demo
//       BMFMapSDK.setCoordType(BMF_COORD_TYPE.BD09LL);
//     }

//     /// iOS端鉴权结果
//     myLocPlugin.getApiKeyCallback(callback: (String result) {
//       String str = result;
//       print('鉴权结果：' + str);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleLocationPage();
//   }

//   // 动态申请定位权限
//   void requestPermission() async {
//     // 申请权限
//     bool hasLocationPermission = await requestLocationPermission();
//     if (hasLocationPermission) {
//       // 权限申请通过
//     } else {}
//   }

//   /// 申请定位权限
//   /// 授予定位权限返回true， 否则返回false
//   Future<bool> requestLocationPermission() async {
//     //获取当前的权限
//     var status = await Permission.location.status;
//     if (status == PermissionStatus.granted) {
//       //已经授权
//       return true;
//     } else {
//       //未授权则发起一次申请
//       status = await Permission.location.request();
//       if (status == PermissionStatus.granted) {
//         return true;
//       } else {
//         return false;
//       }
//     }
//   }
// }
