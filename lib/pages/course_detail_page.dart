import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:final_project/controllers/course_controller.dart';
import 'package:final_project/controllers/enrollment_controller.dart';
import 'package:final_project/core/config/db_helper.dart';
import 'package:final_project/models/enrollment.dart';
import 'package:final_project/pages/course_progress_page.dart';
import 'package:flutter/material.dart';
import 'package:final_project/models/course.dart';
import 'package:final_project/models/section.dart';
import 'package:final_project/models/course_material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final enrollmentController = Get.find<EnrollmentController>();
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

  Future<bool> isOffline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }

  Future<void> _loadSectionsAndMaterials() async {
    try {
      final offline = await isOffline();

      if (offline) {
        final db = DBHelper();
        final fetchedSections = await db.getSectionsByCourseId(widget.course.id);
        final materialsMap = <String, List<CourseMaterial>>{};

        for (final section in fetchedSections) {
          final materials = await db.getMaterialsBySectionId(section.id);
          materialsMap[section.id] = materials;
        }

        setState(() {
          sections = fetchedSections;
          materialsBySection = materialsMap;
          isLoading = false;
        });
      } else {
        final fetchedSections = await courseController.getSectionsByCourseId(widget.course.id);
        final materialsMap = <String, List<CourseMaterial>>{};

        for (final section in fetchedSections) {
          final materials = await courseController.getMaterialsBySectionId(section.id);
          materialsMap[section.id] = materials;
        }

        setState(() {
          sections = fetchedSections;
          materialsBySection = materialsMap;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  void _enrollInCourse() async {
    final enrollmentController = Get.find<EnrollmentController>();
    final courseId = widget.course.id;
    final userId = widget.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede inscribir sin sesión iniciada.')),
      );
      return;
    }

    try {
      await enrollmentController.addEnrollment(
        Enrollment(
          id: '',
          userId: userId,
          courseId: courseId,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te has inscrito en el curso.')),
      );

      setState(() {
        widget.enrolledCourseIds.add(courseId);
      });

      _loadSectionsAndMaterials();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al inscribirse: $e')),
      );
    }
  }

  Future<void> downloadCourse(Course course, List<Section> sections, Map<String, List<CourseMaterial>> materialsBySection) async {
    final dbHelper = DBHelper();

    await dbHelper.insertCourse(course);

    for (final section in sections) {
      await dbHelper.insertSection(section);
      final materials = materialsBySection[section.id] ?? [];
      for (final material in materials) {
        await dbHelper.insertMaterial(material);
      }
    }
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
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSections(),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseProgressPage(courseId: widget.course.id),
                              ),
                            );

                            await enrollmentController.fetchEnrollments();
                            setState(() {});
                          },
                          icon: const Icon(Icons.pie_chart),
                          label: const Text('Ver Progreso'),
                        ),
                        const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await courseController.downloadCourseToLocal(widget.course.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Curso descargado para acceso offline')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al descargar el curso: $e')),
                                );
                              }
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Descargar curso'),
                          ),
                      ],
                    )
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
    final enrollmentController = Get.find<EnrollmentController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) {
        final materials = materialsBySection[section.id] ?? [];
        return _buildInfoCard('Sección: ${section.name}', [
          _buildInfoRow('Descripción', section.description),
          const SizedBox(height: 8),
          const Text('Materiales:', style: TextStyle(fontWeight: FontWeight.bold)),
          for (var material in materials)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(material.title),
              subtitle: Text(material.url),
              onTap: () async {
                await launchUrl(Uri.parse(material.url));

                if (widget.userId != null) {
                  await enrollmentController.markMaterialAsViewed(
                    widget.userId!,
                    widget.course.id,
                    material.id,
                  );

                  await enrollmentController.fetchEnrollments();
                  setState(() {});
                }
              },
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