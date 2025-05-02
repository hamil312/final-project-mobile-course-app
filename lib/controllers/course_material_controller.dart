import 'package:get/get.dart';

import 'package:final_project/models/course_material.dart';
import 'package:final_project/repositories/course_material_repository.dart';

class CourseMaterialController extends GetxController {
  final CourseMaterialRepository repository;

  CourseMaterialController({required this.repository});

  final RxList<CourseMaterial> courseMaterials = <CourseMaterial>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchMaterialsBySection(String sectionId) async {
    try {
      isLoading.value = true;
      final fetchedMaterials = await repository.getCourseMaterials(sectionId);
      courseMaterials.assignAll(fetchedMaterials);
    } catch (e) {
      error.value = e.toString();
      courseMaterials.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCourseMaterial(CourseMaterial courseMaterial) async {
    try {
      final newCourseMaterial = await repository.createCourseMaterial(courseMaterial);
      courseMaterials.add(newCourseMaterial);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> deleteCourseMaterial(String id) async {
    try {
      await repository.deleteCourseMaterial(id);
      courseMaterials.removeWhere((courseMaterial) => courseMaterial.id == id);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> updateCourseMaterial(CourseMaterial courseMaterial) async {
    try {
      final updatedCourseMaterial = await repository.updateCourseMaterial(courseMaterial);
      final index = courseMaterials.indexWhere((u) => u.id == updatedCourseMaterial.id);
      courseMaterials[index] = updatedCourseMaterial;
    } catch (e) {
      error.value = e.toString();
    }
  }
}
