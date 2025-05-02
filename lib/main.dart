import 'package:appwrite/appwrite.dart';
import 'package:final_project/controllers/course_controller.dart';
import 'package:final_project/core/config/app_config.dart';
import 'package:final_project/repositories/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_project/repositories/auth_repository.dart';
import 'package:final_project/controllers/auth_controller.dart';
import 'package:final_project/pages/splash_page.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final client = AppwriteConfig.initClient();
  final databases = Databases(client);
  final account = Account(client);

  Get.put(CourseRepository(databases));
  Get.put(AuthRepository(account));
  Get.put(AuthController(Get.find()));
  
  Get.put(CourseController(repository: Get.find(), authRepository: Get.find()));
  

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App de Cursos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashPage(),
    );
  }
}