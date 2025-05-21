import 'package:final_project/core/config/db_helper.dart';
import 'package:final_project/models/course_material.dart';
import 'package:final_project/models/section.dart';
import 'package:final_project/repositories/auth_repository.dart';
import 'package:get/get.dart';

import 'package:final_project/models/course.dart';
import 'package:final_project/repositories/course_repository.dart';

class CourseController extends GetxController {
  final CourseRepository repository;
  final AuthRepository authRepository;
  final DBHelper localDbHelper;

  CourseController({required this.repository, required this.authRepository, required this.localDbHelper,});

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

  Future<void> downloadCourseToLocal(String courseId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final courses = await repository.getCoursesByIds([courseId]);
      if (courses.isEmpty) throw Exception('Curso no encontrado');
      final course = courses.first;

      final sections = await repository.getSectionsByCourseId(courseId);

      final List<CourseMaterial> allMaterials = [];
      for (final section in sections) {
        final materials = await repository.getMaterialsBySectionId(section.id);
        allMaterials.addAll(materials);
      }

      await localDbHelper.insertCourse(course);
      for (final section in sections) {
        await localDbHelper.insertSection(section);
      }
      for (final material in allMaterials) {
        await localDbHelper.insertMaterial(material);
      }
    } catch (e) {
      error.value = 'Error al descargar el curso: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCoursesFromLocal({required String userId, required bool isAdmin}) async {
    isLoading.value = true;
    final db = DBHelper();

    try {
      final localCourses = await db.getCourses();
      final userEnrollments = await db.getEnrollmentsByUser(userId);//Parece que controller requiere este metodo que no existe

      if (!isAdmin) {
        final enrolledIds = userEnrollments.map((e) => e['courseId'] as String).toList();
        courses.value = localCourses.where((c) => enrolledIds.contains(c.id)).toList();
      } else {
        courses.value = localCourses;
      }

      error.value = '';
    } catch (e) {
      error.value = 'Error cargando cursos offline: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
