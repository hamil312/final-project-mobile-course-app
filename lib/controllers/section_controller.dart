import 'package:get/get.dart';

import 'package:final_project/models/section.dart';
import 'package:final_project/repositories/section_repository.dart';

class SectionController extends GetxController {
  final SectionRepository repository;

  SectionController({required this.repository});

  final RxList<Section> sections = <Section>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchSectionsByCourse(String courseId) async {
    try {
      isLoading.value = true;
      final fetchedSections = await repository.getSectionsByCourse(courseId);
      sections.assignAll(fetchedSections);
    } catch (e) {
      error.value = e.toString();
      sections.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSections() async {
    try {
      isLoading.value = true;
      final fetchedSections = await repository.getSections();
      sections.assignAll(fetchedSections);
    } catch (e) {
      error.value = e.toString();
      sections.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSection(Section section) async {
    try {
      final newSection = await repository.createSection(section);
      sections.add(newSection);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> deleteSection(String id) async {
    try {
      await repository.deleteSection(id);
      sections.removeWhere((section) => section.id == id);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> updateSection(Section section) async {
    try {
      final updatedSection = await repository.updateSection(section);
      final index = sections.indexWhere((u) => u.id == updatedSection.id);
      sections[index] = updatedSection;
    } catch (e) {
      error.value = e.toString();
    }
  }
}
