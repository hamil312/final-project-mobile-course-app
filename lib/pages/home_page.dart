import 'package:final_project/controllers/enrollment_controller.dart';
import 'package:final_project/pages/course_card.dart';
import 'package:final_project/pages/creation_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:final_project/controllers/auth_controller.dart';
import 'package:final_project/controllers/course_controller.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authController = Get.find<AuthController>();
  final courseController = Get.find<CourseController>();
  final enrollmentController = Get.find<EnrollmentController>();

  String userId = '';
  bool isAdmin = false;
  List<String> enrolledCourseIds = [];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    final user = await authController.getUserId();
    final role = await authController.getCurrentUserRole();

    if (user != null) {
      setState(() {
        userId = user;
        isAdmin = role == 'admin';
      });

      if (isAdmin) {
        await courseController.fetchCourses();
      } else {
        await enrollmentController.fetchEnrollments();

        enrolledCourseIds =
            enrollmentController.enrollments.map((e) => e.courseId).toList();

        await courseController.fetchCoursesByIds(enrolledCourseIds);
      }
    } else {
      // Puedes manejar el caso de error aquí (por ejemplo, cerrar sesión o mostrar un error)
      debugPrint('Usuario no autenticado');
      Get.find<AuthController>().logout(); // o navega al login
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Hogar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: GetX<CourseController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (isAdmin)
                IconButton(
                  onPressed: () => Get.to(() => CourseCreator()),
                  icon: const Icon(Icons.add),
                ),
              if (controller.error.value.isNotEmpty)
                Text(
                  'Error: ${controller.error.value}',
                  style: const TextStyle(color: Colors.red),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.courses.length,
                  itemBuilder: (context, index) {
                    final course = controller.courses[index];

                    return Stack(
                      children: [
                        CourseCard(
                          course: course,
                          userId: userId,
                          isAdmin: isAdmin,
                          enrolledCourseIds: enrolledCourseIds,
                        ),
                        if (isAdmin)
                          Positioned(
                            top: 0,
                            right: 8,
                            child: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  // Implementar edición si se desea
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar eliminación'),
                                      content: const Text('¿Está seguro de eliminar este curso?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            controller.deleteCourse(course.id);
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Eliminar'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}