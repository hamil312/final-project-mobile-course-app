import 'package:final_project/models/course_material.dart';
import 'package:final_project/models/section.dart';
import 'package:flutter/material.dart';

class AddSectionForm extends StatefulWidget {
  const AddSectionForm({super.key});

  @override
  State<AddSectionForm> createState() => _AddSectionFormState();
}

class _AddSectionFormState extends State<AddSectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _sectionNameController = TextEditingController();
  final _sectionDescriptionController = TextEditingController();
  final _materialTitleController = TextEditingController();
  final _materialUrlController = TextEditingController();
  final _materialSizeController = TextEditingController();

  final List<CourseMaterial> materials = [];

  @override
  void dispose() {
    _sectionNameController.dispose();
    _sectionDescriptionController.dispose();
    _materialTitleController.dispose();
    _materialUrlController.dispose();
    _materialSizeController.dispose();
    super.dispose();
  }

  void _addMaterial() {
    final title = _materialTitleController.text.trim();
    final url = _materialUrlController.text.trim();
    final sizeText = _materialSizeController.text.trim();

    if (title.isNotEmpty && url.isNotEmpty && int.tryParse(sizeText) != null) {
      setState(() {
        materials.add(CourseMaterial(
          id: '',
          title: title,
          url: url,
          sizeBytes: int.parse(sizeText),
          sectionId: '',
        ));
        _materialTitleController.clear();
        _materialUrlController.clear();
        _materialSizeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Añadir Sección', style: Theme.of(context).textTheme.titleLarge),
                TextFormField(
                  controller: _sectionNameController,
                  decoration: const InputDecoration(labelText: 'Nombre de la sección'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _sectionDescriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 10),
                const Text('Añadir Material', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _materialTitleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextFormField(
                  controller: _materialUrlController,
                  decoration: const InputDecoration(labelText: 'URL'),
                ),
                TextFormField(
                  controller: _materialSizeController,
                  decoration: const InputDecoration(labelText: 'Tamaño (bytes)'),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: _addMaterial,
                  child: const Text('Añadir material'),
                ),
                if (materials.isNotEmpty)
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      itemCount: materials.length,
                      itemBuilder: (context, index) {
                        final mat = materials[index];
                        return ListTile(
                          dense: true,
                          title: Text(mat.title, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${mat.sizeBytes} bytes'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                materials.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final section = Section(
                            id: '',
                            name: _sectionNameController.text,
                            description: _sectionDescriptionController.text,
                            courseId: '',
                          );
                          Navigator.pop(context, {
                            'section': section,
                            'materials': materials,
                          });
                        }
                      },
                      child: const Text('Añadir sección'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}