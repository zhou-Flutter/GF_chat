import 'package:get_it/get_it.dart';
import 'package:my_chat/provider/chat_provider.dart';

GetIt locator = GetIt.instance;

Future<void> setupLocator({bool test = false}) async {
  /// Services 需要什么就注册什么

  // locator.registerFactory<Chat>(() => Chat());

  /// ......
  /// 工具二：剪刀，注册(放入工具箱)
  // locator.registerLazySingleton<ServiceJiandao>(
  //   () => ServiceJiandao(),
  // );
}
