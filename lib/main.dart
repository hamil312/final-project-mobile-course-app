import 'package:appwrite/appwrite.dart';
import 'package:final_project/controllers/course_controller.dart';
import 'package:final_project/controllers/enrollment_controller.dart';
import 'package:final_project/controllers/user_controller.dart';
import 'package:final_project/core/config/app_config.dart';
import 'package:final_project/models/course.dart';
import 'package:final_project/models/course_material.dart';
import 'package:final_project/models/section.dart';
import 'package:final_project/repositories/course_repository.dart';
import 'package:final_project/repositories/enrollment_repository.dart';
import 'package:final_project/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_project/repositories/auth_repository.dart';
import 'package:final_project/controllers/auth_controller.dart';
import 'package:final_project/pages/splash_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(CourseAdapter());
  Hive.registerAdapter(SectionAdapter());
  Hive.registerAdapter(CourseMaterialAdapter());

  await Hive.openBox<Course>('coursesBox');
  await Hive.openBox<Section>('sectionsBox');
  await Hive.openBox<CourseMaterial>('materialsBox');

  final client = AppwriteConfig.initClient();
  final databases = Databases(client);
  final account = Account(client);

  Get.put(CourseRepository(databases));
  Get.put(UserRepository(databases));
  Get.put(EnrollmentRepository(databases));
  Get.put(AuthRepository(account, databases));
  Get.put(AuthController(Get.find()));
  Get.put(CourseController(repository: Get.find(), authRepository: Get.find()));
  Get.put(UserController(repository: Get.find(), authRepository: Get.find()));
  Get.put(EnrollmentController(repository: Get.find(), authRepository: Get.find(), courseRepository: Get.find()));

  runApp(const MyApp());
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