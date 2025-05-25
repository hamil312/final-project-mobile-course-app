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

    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              course.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(course.description),
            const SizedBox(height: 16),
            const Text(
              'Contenido del curso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...sections.map((section) {
              final materials = materialBox.values
                  .where((material) => material.sectionId == section.id)
                  .toList();

              return ExpansionTile(
                title: Text(
                  section.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: materials.map((material) {
                  return ListTile(
                    title: Text(material.url),
                    subtitle: Text(material.title),
                    trailing: const Icon(Icons.picture_as_pdf),
                    onTap: () {
                      // Aquí podrías mostrar el archivo si está disponible localmente
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Abrir archivo: ${material.title}')),
                      );
                    },
                  );
                }).toList(),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}