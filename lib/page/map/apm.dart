import 'dart:async';
import 'dart:io';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:permission_handler/permission_handler.dart';

class AMapPage extends StatelessWidget {
  final String iosKey;
  final String androidKey;

  final LatLng? latLng;
  final void Function(AMapController controller)? onMapCreated;

  const AMapPage(this.iosKey, this.androidKey,
      {Key? key, this.latLng, this.onMapCreated})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CameraPosition kInitialPosition = CameraPosition(
      target: latLng ?? const LatLng(39.909187, 116.397451),
      zoom: 10.0,
    );

    return AMapWidget(
      initialCameraPosition: kInitialPosition,
      buildingsEnabled: false,
      onMapCreated: onCreated,
      privacyStatement: const AMapPrivacyStatement(
          hasShow: true, hasAgree: true, hasContains: true),
      apiKey: AMapApiKey(
        iosKey: iosKey,
        androidKey: androidKey,
      ),
    );
  }

  void onCreated(AMapController controller) {
    AMapApprovalNumber.setApprovalNumber(controller);
    if (onMapCreated != null) onMapCreated!(controller);
  }
}

/// 获取审图号
/// 这里设计的很奇怪，当地图创建后才知道这个号码，但是这个号码不一定要显示在地图之上，却一定要显示在app之内，主要是和上架后的合规有关
class AMapApprovalNumber {
  static String? mapContentApprovalNumber;
  static String? satelliteImageApprovalNumber;

  static Function(String? mapContentApprovalNumber,
      String? satelliteImageApprovalNumber)? _listener;

  static void addListener(
      Function(String? mapContentApprovalNumber,
              String? satelliteImageApprovalNumber)
          run) {
    _listener = run;
  }

  static void setApprovalNumber(AMapController? mapController) async {
    //普通地图审图号
    mapContentApprovalNumber =
        await mapController?.getMapContentApprovalNumber();
    //卫星地图审图号
    satelliteImageApprovalNumber =
        await mapController?.getSatelliteImageApprovalNumber();

    if (kDebugMode) {
      print('地图审图号（普通地图）: $mapContentApprovalNumber');
      print('地图审图号（卫星地图): $satelliteImageApprovalNumber');
    }

    if (_listener != null)
      _listener!(mapContentApprovalNumber, satelliteImageApprovalNumber);
  }
}

mixin AMapLocationStateMixin<WIDGET extends StatefulWidget> on State<WIDGET> {
  String get iosKey;
  String get androidKey;

  /// 是否拥有定位权限
  bool get hasLocationPermission => _hasLocationPermission;

  ///获取到的定位信息
  Map<String, Object> get locationResult => _locationResult ?? {};

  ///整理过的数据
  LocationInfo get locationInfo => LocationInfo(locationResult);

  ///开始定位
  void startLocation() {
    ///开始定位之前设置定位参数
    _setLocationOption();
    _locationPlugin.startLocation();
  }

  ///停止定位
  void stopLocation() {
    _locationPlugin.stopLocation();
  }

  Map<String, Object>? _locationResult;

  StreamSubscription<Map<String, Object>>? _locationListener;

  final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();

  @override
  void initState() {
    super.initState();

    /// 设置是否已经包含高德隐私政策并弹窗展示显示用户查看，如果未包含或者没有弹窗展示，高德定位SDK将不会工作
    ///
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    /// <b>必须保证在调用定位功能之前调用， 建议首次启动App时弹出《隐私政策》并取得用户同意</b>
    ///
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    ///
    /// [hasContains] 隐私声明中是否包含高德隐私政策说明
    ///
    /// [hasShow] 隐私权政策是否弹窗展示告知用户
    AMapFlutterLocation.updatePrivacyShow(true, true);

    /// 设置是否已经取得用户同意，如果未取得用户同意，高德定位SDK将不会工作
    ///
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    ///
    /// <b>必须保证在调用定位功能之前调用, 建议首次启动App时弹出《隐私政策》并取得用户同意</b>
    ///
    /// [hasAgree] 隐私权政策是否已经取得用户同意
    AMapFlutterLocation.updatePrivacyAgree(true);

    /// 动态申请定位权限
    _requestLocationPermission();

    ///设置Android和iOS的apiKey<br>
    ///key的申请请参考高德开放平台官网说明<br>
    ///Android: https://lbs.amap.com/api/android-location-sdk/guide/create-project/get-key
    ///iOS: https://lbs.amap.com/api/ios-location-sdk/guide/create-project/get-key
    AMapFlutterLocation.setApiKey(androidKey, iosKey);

    ///iOS 获取native精度类型
    if (Platform.isIOS) {
      _requestAccuracyAuthorization();
    }

    ///注册定位结果监听
    _locationListener = _locationPlugin
        .onLocationChanged()
        .listen((Map<String, Object> result) {
      setState(() {
        _locationResult = result;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    ///移除定位监听
    if (null != _locationListener) {
      _locationListener?.cancel();
    }

    ///销毁定位
    _locationPlugin.destroy();
  }

  ///设置定位参数
  void _setLocationOption() {
    AMapLocationOption locationOption = AMapLocationOption();

    ///是否单次定位
    locationOption.onceLocation = false;

    ///是否需要返回逆地理信息
    locationOption.needAddress = true;

    ///逆地理信息的语言类型
    locationOption.geoLanguage = GeoLanguage.DEFAULT;

    locationOption.desiredLocationAccuracyAuthorizationMode =
        AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;

    locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

    ///设置Android端连续定位的定位间隔
    locationOption.locationInterval = 2000;

    ///设置Android端的定位模式<br>
    ///可选值：<br>
    ///<li>[AMapLocationMode.Battery_Saving]</li>
    ///<li>[AMapLocationMode.Device_Sensors]</li>
    ///<li>[AMapLocationMode.Hight_Accuracy]</li>
    locationOption.locationMode = AMapLocationMode.Hight_Accuracy;

    ///设置iOS端的定位最小更新距离<br>
    locationOption.distanceFilter = -1;

    ///设置iOS端期望的定位精度
    /// 可选值：<br>
    /// <li>[DesiredAccuracy.Best] 最高精度</li>
    /// <li>[DesiredAccuracy.BestForNavigation] 适用于导航场景的高精度 </li>
    /// <li>[DesiredAccuracy.NearestTenMeters] 10米 </li>
    /// <li>[DesiredAccuracy.Kilometer] 1000米</li>
    /// <li>[DesiredAccuracy.ThreeKilometers] 3000米</li>
    locationOption.desiredAccuracy = DesiredAccuracy.Best;

    ///设置iOS端是否允许系统暂停定位
    locationOption.pausesLocationUpdatesAutomatically = false;

    ///将定位参数设置给定位插件
    _locationPlugin.setLocationOption(locationOption);
  }

  ///获取iOS native的accuracyAuthorization类型
  Future<AMapAccuracyAuthorization> _requestAccuracyAuthorization() async {
    AMapAccuracyAuthorization currentAccuracyAuthorization =
        await _locationPlugin.getSystemAccuracyAuthorization();
    if (kDebugMode) {
      if (currentAccuracyAuthorization ==
          AMapAccuracyAuthorization.AMapAccuracyAuthorizationFullAccuracy) {
        print("精确定位类型");
      } else if (currentAccuracyAuthorization ==
          AMapAccuracyAuthorization.AMapAccuracyAuthorizationReducedAccuracy) {
        print("模糊定位类型");
      } else {
        print("未知定位类型");
      }
    }

    return currentAccuracyAuthorization;
  }

  bool _hasLocationPermission = false;

  /// 申请定位权限
  Future<void> _requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      //已经授权
      _hasLocationPermission = true;
    } else {
      //未授权则发起一次申请
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        _hasLocationPermission = true;
      } else {
        _hasLocationPermission = false;
      }
    }

    if (kDebugMode) {
      if (_hasLocationPermission) {
        print("定位权限申请通过");
      } else {
        print("定位权限申请不通过");
      }
    }
  }
}

class LocationInfo {
  //TODO:应当再此类对信息做转换，明确数据类型

  String? locTime;
  String? province;
  String? callbackTime;
  String? district;
  double? speed;

  double? latitude;
  double? longitude;

  String? country;
  String? city;
  String? cityCode;
  String? street;
  String? streetNumber;
  String? address;
  String? description;

  double? bearing;
  double? accuracy;
  String? adCode;
  double? altitude;
  int? locationType;

  LocationInfo(Map<String, Object> locationResult) {
    locTime = locationResult["locTime"] as String;
    province = locationResult["province"] as String;
    callbackTime = locationResult["callbackTime"] as String;
    district = locationResult["district"] as String;
    speed = locationResult["speed"] as double;

    latitude = double.parse(locationResult["latitude"] as String);
    longitude = double.parse(locationResult["longitude"] as String);

    country = locationResult["country"] as String;
    city = locationResult["city"] as String;
    cityCode = locationResult["cityCode"] as String;
    street = locationResult["street"] as String;
    streetNumber = locationResult["streetNumber"] as String;
    address = locationResult["address"] as String;
    description = locationResult["description"] as String;

    bearing = locationResult["bearing"] as double;
    accuracy = locationResult["accuracy"] as double;
    adCode = locationResult["adCode"] as String;
    altitude = locationResult["altitude"] as double;
    locationType = locationResult["locationType"] as int;
  }
}
