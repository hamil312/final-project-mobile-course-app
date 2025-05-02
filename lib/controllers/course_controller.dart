import 'package:final_project/models/course_material.dart';
import 'package:final_project/models/section.dart';
import 'package:final_project/repositories/auth_repository.dart';
import 'package:get/get.dart';

import 'package:final_project/models/course.dart';
import 'package:final_project/repositories/course_repository.dart';

class CourseController extends GetxController {
  final CourseRepository repository;
  final AuthRepository authRepository;

  CourseController({required this.repository, required this.authRepository});

  final RxList<Course> courses = <Course>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchCourses() async {
    try {
      isLoading.value = true;
      final authorId = await authRepository.getCurrentUserId();
      if (authorId == null) throw Exception('Sesión no iniciada');
      final fetchedCourses = await repository.getCourses(authorId);
      courses.assignAll(fetchedCourses);
    } catch (e) {
      error.value = e.toString();
      courses.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCourse(
    Course course,
    List<Section> sections,
    Map<String, List<CourseMaterial>> sectionMaterials,
  ) async {
    try {
      isLoading.value = true;
      error.value = '';

      final authorId = await authRepository.getCurrentUserId();
      if (authorId == null) throw Exception('No hay sesión activa');

      final createdCourse = await repository.createCourse(
        course.copyWith(id: '', authorId: authorId),
      );

      final courseId = createdCourse.id;

      for (final section in sections) {
        final createdSection = await repository.createSection(
          section.copyWith(courseId: courseId),
        );

        final sectionId = createdSection.id;

        final materials = sectionMaterials[section.name] ?? [];
        for (final material in materials) {
          await repository.createMaterial(
            material.copyWith(sectionId: sectionId),
          );
        }
      }

      courses.add(createdCourse);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await repository.deleteCourse(courseId);
      courses.removeWhere((course) => course.id == courseId);
    } catch (e) {
      error.value = e.toString();
    }
  }


  Future<void> updateCourse(String authorId, Course course) async {
    try {
      final updatedCourse = await repository.updateCourse(authorId, course);
      final index = courses.indexWhere((u) => u.id == authorId);
      if (index != -1) {
        courses[index] = updatedCourse;
      }
    } catch (e) {
      error.value = e.toString();
    }
  }
}
