import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:final_project/controllers/enrollment_controller.dart';
import 'package:final_project/models/course_material.dart';
import 'package:final_project/pages/course_card.dart';
import 'package:final_project/pages/creation_page.dart';
import 'package:final_project/pages/update_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:final_project/controllers/auth_controller.dart';
import 'package:final_project/controllers/course_controller.dart';

enum ViewMode { myCourses, feed }

ViewMode currentView = ViewMode.myCourses;

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

  Future<bool> isOffline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }

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

      final offline = await isOffline();

      if (offline) {
        // Si estás offline, cargar cursos desde SQLite
        await courseController.loadCoursesFromLocal(userId: userId, isAdmin: isAdmin);
      } else {
        if (isAdmin) {
          await courseController.fetchCourses(); // Appwrite
        } else {
          await enrollmentController.fetchEnrollments(); // Appwrite
          enrolledCourseIds =
              enrollmentController.enrollments.map((e) => e.courseId).toList();
          await courseController.fetchCoursesByIds(enrolledCourseIds); // Appwrite
        }
      }
    } else {
      debugPrint('Usuario no autenticado');
      Get.find<AuthController>().logout();
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
          final coursesToShow = controller.courses.where((course) {
            if (currentView == ViewMode.myCourses && !isAdmin) {
              return enrolledCourseIds.contains(course.id);
            }
            return true;
          }).toList();

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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() => currentView = ViewMode.myCourses);
                      if (isAdmin) {
                        courseController.fetchCourses();
                      } else {
                        courseController.fetchCoursesByIds(enrolledCourseIds);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentView == ViewMode.myCourses
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    child: const Text('Mis cursos'),
                  ),
                  const SizedBox(width: 8),
                  if (!isAdmin)
                  ElevatedButton(
                    onPressed: () {
                      setState(() => currentView = ViewMode.feed);
                      courseController.fetchAllCourses();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentView == ViewMode.feed
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    child: const Text('Explorar cursos'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: coursesToShow.length,
                  itemBuilder: (context, index) {
                    final course = coursesToShow[index];

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
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final sections = await courseController.getSectionsByCourseId(course.id);
                                  final sectionMaterials = <String, List<CourseMaterial>>{};

                                  for (final section in sections) {
                                    final materials = await courseController.getMaterialsBySectionId(section.id);
                                    sectionMaterials[section.name] = materials;
                                  }

                                  Get.to(() => CourseEditor(
                                    course: course,
                                    initialSections: sections,
                                    initialSectionMaterials: sectionMaterials,
                                  ));
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