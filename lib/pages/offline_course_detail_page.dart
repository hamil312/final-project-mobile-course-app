import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:final_project/models/course.dart';
import 'package:final_project/models/section.dart';
import 'package:final_project/models/course_material.dart';

class OfflineCourseDetailPage extends StatelessWidget {
  final String courseId;

  const OfflineCourseDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final courseBox = Hive.box<Course>('coursesBox');
    final sectionBox = Hive.box<Section>('sectionsBox');
    final materialBox = Hive.box<CourseMaterial>('materialsBox');

    final course = courseBox.get(courseId);

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Curso no encontrado')),
        body: const Center(child: Text('No se encontró el curso offline.')),
      );
    }

    final sections = sectionBox.values
        .where((section) => section.courseId == course.id)
        .toList();

    final materialsBySection = <String, List<CourseMaterial>>{};
    for (final section in sections) {
      final materials = materialBox.values
          .where((material) => material.sectionId == section.id)
          .toList();
      materialsBySection[section.id] = materials;
    }

    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoCard('Información general', [
              _buildInfoRow('ID', course.id),
              _buildInfoRow('Nombre', course.name),
              _buildInfoRow('Descripción', course.description),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Temas', [
              for (var tema in course.themes)
                _buildInfoRow('Tema', tema),
            ]),
            const SizedBox(height: 16),
            ...sections.map((section) {
              final materials = materialsBySection[section.id] ?? [];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildInfoCard('Sección: ${section.name}', [
                  _buildInfoRow('Descripción', section.description),
                  const SizedBox(height: 8),
                  const Text('Materiales:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (final material in materials)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(material.title),
                      subtitle: Text(material.url),
                    ),
                ]),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}