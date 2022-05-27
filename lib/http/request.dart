import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_chat/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Request {
  // 配置 Dio 实例
  static BaseOptions? _options = BaseOptions(
    connectTimeout: 10000,
    receiveTimeout: 10000,
  );

  // 创建 Dio 实例
  static Dio _dio = Dio(_options);

  /*
     _request 是核心函数，所有的请求都会走这里
  */
  static Future<T> _request<T>(
    String path, {
    String? method,
    Map<String, dynamic>? params,
    data,
    bool? loading,
  }) async {
    // String? TOKEN = await _getToken();

    /// token
    // if (TOKEN != null) _dio.options.headers['Authorization'] = TOKEN;
    _dio.options.headers['connection'] = 'close';
    _dio.options.headers['content-type'] = 'application/json';
    _dio.options.method = method!;
    _dio.options.baseUrl = Constant.url;

    try {
      EasyLoading.show(status: '加载中...');

      Response response = await _dio.request(
        path,
        data: data,
        queryParameters: params,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          if (response.data['code'] != 200) {
            print('响应的数据为：${response.data}');

            EasyLoading.dismiss();

            return Future.error(response.data);
          } else {
            print('响应的数据为：$path:${response.data.toString()}');

            if (response.data is Map) {
              return response.data;
            } else {
              return json.decode(response.data.toString());
            }
          }
        } catch (e) {
          EasyLoading.dismiss();

          print('解析响应数据异常');
          return Future.error('解析响应数据异常');
        }
      } else {
        print('HTTP错误，状态码为：${response.statusCode}');

        handleHttpError(response.statusCode);

        return Future.error('HTTP错误');
      }
    } on DioError catch (e, s) {
      EasyLoading.dismiss();
      print('请求异常:${dioError(e)}');
      return Future.error(e);
    } catch (e, s) {
      EasyLoading.dismiss();
      return Future.error('未知异常');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // 处理 Dio 异常
  static String dioError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectTimeout:
        return "网络连接超时，请检查网络设置";
      case DioErrorType.receiveTimeout:
        return "服务器异常，请稍后重试！";
      case DioErrorType.sendTimeout:
        return "网络连接超时，请检查网络设置";
      case DioErrorType.response:
        return "服务器异常，请稍后重试！";
      case DioErrorType.cancel:
        return "请求已被取消，请重新请求";
      default:
        // return "Dio异常";
        return "出错了，请稍后再试！";
    }
  }

  // 处理 Http 错误码
  static void handleHttpError(int? errorCode) {
    String message;
    switch (errorCode) {
      case 400:
        message = '请求语法错误';
        break;
      case 401:
        message = '未授权，请登录';
        break;
      case 403:
        message = '拒绝访问';
        break;
      case 404:
        message = '请求出错';
        break;
      case 408:
        message = '请求超时';
        break;
      case 500:
        message = '服务器异常';
        break;
      case 501:
        message = '服务未实现';
        break;
      case 502:
        message = '网关错误';
        break;
      case 503:
        message = '服务不可用';
        break;
      case 504:
        message = '网关超时';
        break;
      case 505:
        message = 'HTTP版本不受支持';
        break;
      default:
        message = '请求失败，错误码：$errorCode';
    }
    Fluttertoast.showToast(msg: message, gravity: ToastGravity.BOTTOM);
  }

  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? TOKEN = prefs.getString('TOKEN');
    return TOKEN;
  }

  static Future<T> get<T>(
    String path, {
    Map<String, dynamic>? params,
    bool loading: true,
    CancelToken? cancelToken,
  }) {
    return _request(
      path,
      method: 'get',
      params: params,
      loading: loading,
    );
  }

  static Future<T> post<T>(
    String path, {
    Map<String, dynamic>? params,
    data,
    bool loading: true,
    CancelToken? cancelToken,
  }) {
    return _request(
      path,
      method: 'post',
      params: params,
      data: data,
      loading: loading,
    );
  }
}
