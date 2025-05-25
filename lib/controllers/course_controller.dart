import 'package:final_project/models/course_material.dart';
import 'package:final_project/models/section.dart';
import 'package:final_project/repositories/auth_repository.dart';
import 'package:get/get.dart';

import 'package:final_project/models/course.dart';
import 'package:final_project/repositories/course_repository.dart';
import 'package:hive/hive.dart';

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

  Future<void> fetchAllCourses() async {
    try {
      isLoading.value = true;
      final fetchedCourses = await repository.getAllCourses();
      courses.assignAll(fetchedCourses);
    } catch (e) {
      error.value = e.toString();
      courses.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCoursesByIds(List<String> courseIds) async {
    try {
      isLoading.value = true;
      error.value = '';
      final fetchedCourses = await repository.getCoursesByIds(courseIds);
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
      error.value = '';
      isLoading.value = true;

      final sections = await repository.getSectionsByCourseId(courseId);

      for (final section in sections) {

        final materials = await repository.getMaterialsBySectionId(section.id);

        for (final material in materials) {
          await repository.deleteMaterial(material.id);
        }

        await repository.deleteSection(section.id);
      }

      await repository.deleteCourse(courseId);

      courses.removeWhere((course) => course.id == courseId);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> updateCourse(
    Course updatedCourse,
    List<Section> updatedSections,
    Map<String, List<CourseMaterial>> updatedSectionMaterials,
  ) async {
    try {
      isLoading.value = true;
      error.value = '';

      final course = await repository.updateCourse(updatedCourse);

      final oldSections = await repository.getSectionsByCourseId(course.id);
      for (final section in oldSections) {
        final materials = await repository.getMaterialsBySectionId(section.id);
        for (final material in materials) {
          await repository.deleteMaterial(material.id);
        }
        await repository.deleteSection(section.id);
      }

      for (final section in updatedSections) {
        final createdSection = await repository.createSection(
          section.copyWith(courseId: course.id),
        );
        final sectionId = createdSection.id;
        final materials = updatedSectionMaterials[section.name] ?? [];
        for (final material in materials) {
          await repository.createMaterial(
            material.copyWith(sectionId: sectionId),
          );
        }
      }

      final index = courses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        courses[index] = course;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Section>> getSectionsByCourseId(String courseId) async {
    try {
      return await repository.getSectionsByCourseId(courseId);
    } catch (e) {
      error.value = e.toString();
      return [];
    }
  }

  Future<List<CourseMaterial>> getMaterialsBySectionId(String sectionId) async {
    try {
      return await repository.getMaterialsBySectionId(sectionId);
    } catch (e) {
      error.value = e.toString();
      return [];
    }
  }
  List<Course> getDownloadedCourses() {
    final box = Hive.box<Course>('coursesBox');
    return box.values.toList();
  }
}
