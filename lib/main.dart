import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:toastification/toastification.dart';

import 'binding/app_binding.dart';
import 'controller/theme_controller.dart';
import 'routes/app_pages.dart';
import 'utils/config.dart';
import 'utils/connection.dart';
import 'utils/theme_config.dart';
import 'widgets/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await waitForInternet();
  runApp(const App());
}

Future<bool> waitForInternet({int retries = 5}) async {
  for (int i = 0; i < retries; i++) {
    final isConnected = await Connection.checkInternet();
    if (isConnected) return true;
    await Future.delayed(const Duration(seconds: 3));
  }
  return false;
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    themeController = Get.put(ThemeController());
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return ToastificationWrapper(
          child: GetMaterialApp(
            navigatorKey: ToastHelper.navigatorKey,
            title: Config.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeConfig.lightTheme(),
            darkTheme: ThemeConfig.darkTheme(),
            themeMode: themeController.themeMode.value,
            initialRoute: AppPages.INITIAL_ROUTE,
            initialBinding: AppBinding(),
            getPages: AppPages.route,
          ),
        );
      },
    );
  }
}
