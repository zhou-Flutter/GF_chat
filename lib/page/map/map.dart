// import 'package:flutter/material.dart';
// import 'package:amap_flutter_map/amap_flutter_map.dart';
// import 'package:amap_flutter_base/amap_flutter_base.dart';
// import 'package:my_chat/page/map/apm.dart';

// import 'package:permission_handler/permission_handler.dart';
// import 'package:permission_handler/permission_handler.dart';

// class Maps extends StatefulWidget {
//   const Maps({Key? key}) : super(key: key);

//   @override
//   State<Maps> createState() => _MapsState();
// }

// class _MapsState extends State<Maps> {
//   @override
//   Widget build(BuildContext context) {
//     return _ShowMapPageBody();
//   }
// }

// class _ShowMapPageBody extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _ShowMapPageState();
// }

// class _ShowMapPageState extends State<_ShowMapPageBody>
//     with AMapLocationStateMixin {
//   @override
//   String get iosKey => 'f43627c1ee742cb732dc2198f00c4dae';

//   @override
//   String get androidKey => 'f43627c1ee742cb732dc2198f00c4dae';

//   String? get mapContentApprovalNumber =>
//       AMapApprovalNumber.mapContentApprovalNumber;
//   String? get satelliteImageApprovalNumber =>
//       AMapApprovalNumber.satelliteImageApprovalNumber;

//   @override
//   void initState() {
//     super.initState();

//     startLocation();
//   }

//   AMapController? aMapController;

//   @override
//   Widget build(BuildContext context) {
//     final AMapPage map = AMapPage(
//       iosKey,
//       androidKey,
//       onMapCreated: (AMapController controller) {
//         aMapController = controller;
//       },
//     );

//     List<Widget> approvalNumberWidget = [
//       if (null != mapContentApprovalNumber) Text(mapContentApprovalNumber!),
//       if (null != satelliteImageApprovalNumber)
//         Text(satelliteImageApprovalNumber!),
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("高德地图"),
//         actions: [
//           TextButton(
//               onPressed: () {
//                 LatLng latlng = LatLng(locationInfo.latitude ?? 39.909187,
//                     locationInfo.longitude ?? 116.397451);
//                 CameraUpdate cameraUpdate = CameraUpdate.newLatLng(latlng);
//                 aMapController?.moveCamera(cameraUpdate);
//               },
//               child: const Icon(
//                 Icons.location_on_rounded,
//                 color: Colors.red,
//               ))
//         ],
//       ),
//       body: map,
//       drawer: Container(
//         color: Colors.white,
//         child: SafeArea(
//           child: Column(
//             children: [
//               createButtonContainer(),
//               Expanded(child: resultList()),
//               ...approvalNumberWidget,
//             ],
//           ),
//         ),
//         width: MediaQuery.of(context).size.width * 0.8,
//       ),
//     );
//   }

//   Widget createButtonContainer() {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: <Widget>[
//         ElevatedButton(
//           onPressed: startLocation,
//           child: const Text('开始定位'),
//           style: ButtonStyle(
//             backgroundColor: MaterialStateProperty.all(Colors.blue),
//             foregroundColor: MaterialStateProperty.all(Colors.white),
//           ),
//         ),
//         Container(width: 20.0),
//         ElevatedButton(
//           onPressed: stopLocation,
//           child: const Text('停止定位'),
//           style: ButtonStyle(
//             backgroundColor: MaterialStateProperty.all(Colors.blue),
//             foregroundColor: MaterialStateProperty.all(Colors.white),
//           ),
//         )
//       ],
//     );
//   }

//   Widget resultList() {
//     List<Widget> widgets = <Widget>[];

//     locationResult.forEach((key, value) {
//       widgets.add(
//         Text(
//           '$key: $value',
//           softWrap: true,
//           style: const TextStyle(color: Colors.lightGreenAccent),
//         ),
//       );
//     });

//     return ListView(
//       children: widgets,
//       padding: const EdgeInsets.all(8),
//     );
//   }
// }
