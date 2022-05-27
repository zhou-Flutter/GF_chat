//极光 Verify

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_chat/http/request.dart';

class JvRequest {
  static Dio? _dio;

  static Dio? getInstance() {
    if (_dio == null) {
      _dio = Dio();
      _dio?.options.connectTimeout = 10000;
    }
    return _dio;
  }

  static Future request(
    String path, {
    String? method,
    Map<String, dynamic>? params,
    data,
    loading = false,
  }) async {
    getInstance();

    Map<String, dynamic>? headers = {
      'content-type': 'application/json',
      '683e39a84c5223571f27216e': 'a31624a988aee78ec1defa30',
    };

    try {
      EasyLoading.show(status: '加载中...');

      Response response = await _dio!.request(path,
          data: data,
          queryParameters: params,
          options: Options(method: method, headers: headers));

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          if (response.data is Map) {
            return response.data;
          } else {
            return json.decode(response.data.toString());
          }
        } catch (e) {
          print('解析响应数据异常');
          return Future.error('解析响应数据异常');
        }
      } else {
        print('HTTP错误，状态码为：${response.statusCode}');
        Request.handleHttpError(response.statusCode);
        return Future.error('HTTP错误');
      }
    } on DioError catch (e, s) {
      EasyLoading.dismiss();
      print('请求异常:${Request.dioError(e)}');
      return Future.error(e);
    } catch (e, s) {
      EasyLoading.dismiss();
      return Future.error('未知异常');
    } finally {
      EasyLoading.dismiss();
    }
  }
}
