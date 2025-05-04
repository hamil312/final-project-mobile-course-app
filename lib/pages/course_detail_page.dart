import 'package:final_project/controllers/course_controller.dart';
import 'package:flutter/material.dart';
import 'package:final_project/models/course.dart';
import 'package:final_project/models/section.dart';
import 'package:final_project/models/course_material.dart';
import 'package:get/get.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;
  final String? userId;
  final bool isAdmin;
  final List<String> enrolledCourseIds;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.userId,
    required this.isAdmin,
    required this.enrolledCourseIds,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final courseController = Get.find<CourseController>();
  List<Section> sections = [];
  Map<String, List<CourseMaterial>> materialsBySection = {};
  bool isLoading = true;

  bool get isEnrolled =>
      widget.enrolledCourseIds.contains(widget.course.id) || widget.isAdmin;

  @override
  void initState() {
    super.initState();
    if (isEnrolled) _loadSectionsAndMaterials();
  }

  Future<void> _loadSectionsAndMaterials() async {
    try {
      final fetchedSections =
          await courseController.getSectionsByCourseId(widget.course.id);
      final materialsMap = <String, List<CourseMaterial>>{};

      for (final section in fetchedSections) {
        final materials =
            await courseController.getMaterialsBySectionId(section.id);
        materialsMap[section.id] = materials;
      }

      setState(() {
        sections = fetchedSections;
        materialsBySection = materialsMap;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  void _enrollInCourse() {
    // Aquí deberías implementar tu lógica para inscribirse en el curso
    // Luego podrías actualizar el estado para refrescar la vista
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Te has inscrito en el curso.')),
    );
    setState(() {
      widget.enrolledCourseIds.add(widget.course.id);
    });
    _loadSectionsAndMaterials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Información general', [
              _buildInfoRow('ID', widget.course.id),
              _buildInfoRow('Nombre', widget.course.name),
              _buildInfoRow('Descripción', widget.course.description),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Temas', [
              for (var tema in widget.course.themes)
                _buildInfoRow('Tema', tema),
            ]),
            const SizedBox(height: 16),
            if (isEnrolled)
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSections()
            else
              Center(
                child: ElevatedButton(
                  onPressed: _enrollInCourse,
                  child: const Text('Inscribirse al curso'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) {
        final materials = materialsBySection[section.id] ?? [];
        return _buildInfoCard('Sección: ${section.name}', [
          _buildInfoRow('Descripción', section.description),
          const SizedBox(height: 8),
          Text('Materiales:', style: TextStyle(fontWeight: FontWeight.bold)),
          for (var material in materials)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(material.title),
              subtitle: Text(material.url),
            ),
        ]);
      }).toList(),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2.0,
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