import 'package:final_project/controllers/auth_controller.dart';
import 'package:final_project/controllers/course_controller.dart';
import 'package:final_project/models/course.dart';
import 'package:final_project/models/course_material.dart';
import 'package:final_project/models/section.dart';
import 'package:final_project/pages/section_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourseEditor extends StatefulWidget {
  final Course course;
  final List<Section> initialSections;
  final Map<String, List<CourseMaterial>> initialSectionMaterials;

  const CourseEditor({
    super.key,
    required this.course,
    required this.initialSections,
    required this.initialSectionMaterials,
  });

  @override
  State<CourseEditor> createState() => _CourseEditorState();
}

class _CourseEditorState extends State<CourseEditor> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _themeController = TextEditingController();
  final List<Section> sections = [];
  final Map<String, List<CourseMaterial>> sectionMaterials = {};
  final List<String> themes = [];

  final CourseController courseController = Get.find();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.course.name;
    _descriptionController.text = widget.course.description;
    themes.addAll(widget.course.themes);
    sections.addAll(widget.initialSections);
    sectionMaterials.addAll(widget.initialSectionMaterials);
  }

  Future<void> _submitCourse(CourseController controller) async {
    if (_formKey.currentState!.validate()) {
      final updatedCourse = Course(
        id: widget.course.id,
        name: _nameController.text,
        description: _descriptionController.text,
        authorId: widget.course.authorId,
        themes: themes,
      );

      await controller.updateCourse(updatedCourse, sections, sectionMaterials);

      if (controller.error.value.isEmpty) {
        Get.snackbar('Éxito', 'Curso actualizado correctamente');
      } else {
        Get.snackbar('Error', controller.error.value);
      }
    }
  }

  Future<void> _showAddSectionDialog() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 16,
          right: 16,
        ),
        child: const AddSectionForm(),
      ),
    );

    if (result != null) {
      final Section section = result['section'];
      final List<CourseMaterial> materials = result['materials'];

      setState(() {
        sections.add(section);
        sectionMaterials[section.name] = materials;
      });
    }
  }

  Future<void> _showEditSectionDialog(Section section, List<CourseMaterial> materials, int index) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 16,
          right: 16,
        ),
        child: AddSectionForm(
          initialSection: section,
          initialMaterials: materials,
        ),
      ),
    );

    if (result != null) {
      final Section updatedSection = result['section'];
      final List<CourseMaterial> updatedMaterials = result['materials'];

      setState(() {
        sections[index] = updatedSection;
        sectionMaterials.remove(section.name);
        sectionMaterials[updatedSection.name] = updatedMaterials;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Curso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          )
        ],
      ),
      body: GetX<CourseController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _themeController,
                            decoration:
                                const InputDecoration(labelText: 'Tema'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final themeText = _themeController.text.trim();
                            if (themeText.isNotEmpty &&
                                !themes.contains(themeText)) {
                              setState(() {
                                themes.add(themeText);
                                _themeController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (themes.isNotEmpty)
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          itemCount: themes.length,
                          itemBuilder: (context, index) {
                            final theme = themes[index];
                            return ListTile(
                              title: Text(theme),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    themes.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Secciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: _showAddSectionDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Añadir Sección'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (sections.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sections.length,
                        itemBuilder: (context, index) {
                          final section = sections[index];
                          return ListTile(
                            title: Text(section.name),
                            subtitle: Text(section.description),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditSectionDialog(
                                      section,
                                      sectionMaterials[section.name] ?? [],
                                      index,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      sectionMaterials.remove(section.name);
                                      sections.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _submitCourse(controller),
                      child: const Text('Actualizar Curso'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
