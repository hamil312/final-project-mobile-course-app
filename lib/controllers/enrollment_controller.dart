import 'package:final_project/controllers/course_controller.dart';
import 'package:final_project/models/course_material.dart';
import 'package:final_project/repositories/auth_repository.dart';
import 'package:final_project/repositories/course_repository.dart';
import 'package:get/get.dart';

import 'package:final_project/models/enrollment.dart';
import 'package:final_project/repositories/enrollment_repository.dart';

class EnrollmentController extends GetxController {
  final EnrollmentRepository repository;
  final AuthRepository authRepository;
  final CourseRepository courseRepository;

  EnrollmentController({required this.repository, required this.authRepository, required this.courseRepository});

  final RxList<Enrollment> enrollments = <Enrollment>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchEnrollments() async {
    try {
      isLoading.value = true;
      final userId = await authRepository.getCurrentUserId();
      if (userId == null) throw Exception('Sesión no iniciada');
      final fetchedEnrollments = await repository.getEnrollments(userId);
      enrollments.assignAll(fetchedEnrollments);
    } catch (e) {
      error.value = e.toString();
      enrollments.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addEnrollment(
    Enrollment enrollment,
  ) async {
    try {
      isLoading.value = true;
      error.value = '';

      final userId = await authRepository.getCurrentUserId();
      if (userId == null) throw Exception('No hay sesión activa');

      bool alreadyEnrolled = enrollments.any((e) => e.courseId == enrollment.courseId);
      if (alreadyEnrolled) {
        throw Exception('Ya estás inscrito en este curso');
      }

      final createdEnrollment = await repository.createEnrollment(
        enrollment.copyWith(id: '', userId: userId),
      );

      enrollments.add(createdEnrollment);
    } catch (e) {
      print('Error en addEnrollment: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEnrollment(String id) async {
    try {
      error.value = '';
      isLoading.value = true;

      await repository.deleteEnrollment(id);

      enrollments.removeWhere((enrollment) => enrollment.id == id);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> updateEnrollment(String id, Enrollment enrollment) async {
    try {
      final updatedEnrollment = await repository.updateEnrollment(id, enrollment);
      final index = enrollments.indexWhere((u) => u.id == id);
      if (index != -1) {
        enrollments[index] = updatedEnrollment;
      }
    } catch (e) {
      error.value = e.toString();
    }
  }

Future<void> markMaterialAsViewed(String userId, String courseId, String materialId) async {
    try {
      final enrollment = enrollments.firstWhereOrNull((e) => e.courseId == courseId);
      if (enrollment == null) return;

      if (!enrollment.viewedMaterialIds.contains(materialId)) {
        enrollment.viewedMaterialIds.add(materialId);

        await repository.updateEnrollment(enrollment.id, enrollment);

        enrollments.refresh();
      }
    } catch (e) {
      print('Error al marcar material como visto: $e');
    }
  }

  int getCompletionRateForCourse(String courseId, List<CourseMaterial> allMaterials) {
    final enrollment = enrollments.firstWhereOrNull((e) => e.courseId == courseId);
    if (enrollment == null) return 0;

    return enrollment.calculateCompletionRate(allMaterials.length);
  }

  Future<int> getTotalMaterialsForCourseU(String courseId) async {
    try {
      final materials = await courseRepository.getMaterialsForCourse(courseId);
      return materials.length;
    } catch (e) {
      error.value = 'Error al obtener materiales: $e';
      return 0;
    }
  }

  Future<int> getTotalMaterialsForCourse(String courseId) async {
    final courseController = Get.find<CourseController>();

    final sections = await courseController.getSectionsByCourseId(courseId);
    int totalMaterials = 0;

    for (final section in sections) {
      final materials = await courseController.getMaterialsBySectionId(section.id);
      totalMaterials += materials.length;
    }

    return totalMaterials;
  }
}
