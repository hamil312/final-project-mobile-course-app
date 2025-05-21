import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:final_project/core/constants/appwrite_constants.dart';
import 'package:final_project/models/course_material.dart';
import 'package:final_project/models/section.dart';
import 'package:flutter/material.dart';

class AddSectionForm extends StatefulWidget {
  final Section? initialSection;
  final List<CourseMaterial>? initialMaterials;

  const AddSectionForm({
    super.key,
    this.initialSection,
    this.initialMaterials,
  });

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

  static final Client client = Client()
    ..setEndpoint(AppwriteConstants.endpoint)
    ..setProject(AppwriteConstants.projectId)
    ..setSelfSigned();
  
  late final Storage storage;

  final List<CourseMaterial> materials = [];

  @override
  void initState() {
    super.initState();
    storage = Storage(client);
    if (widget.initialSection != null) {
      _sectionNameController.text = widget.initialSection!.name;
      _sectionDescriptionController.text = widget.initialSection!.description;
    }
    if (widget.initialMaterials != null) {
      materials.addAll(widget.initialMaterials!);
    }
  }

  @override
  void dispose() {
    _sectionNameController.dispose();
    _sectionDescriptionController.dispose();
    _materialTitleController.dispose();
    _materialUrlController.dispose();
    _materialSizeController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      try {
        final response = await storage.createFile(
          bucketId: AppwriteConstants.bucketId,
          fileId: ID.unique(),
          file: InputFile.fromBytes(
            bytes: fileBytes,
            filename: fileName,
          ),
        );

        final url = 'https://fra.cloud.appwrite.io/v1/storage/buckets/${AppwriteConstants.bucketId}/files/${response.$id}/view?project=${AppwriteConstants.projectId}&mode=admin';

        setState(() {
          materials.add(CourseMaterial(
            id: '',
            title: fileName,
            url: url,
            sizeBytes: fileBytes.length,
            sectionId: '',
          ));
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir archivo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialSection != null;

    return SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing ? 'Editar Sección' : 'Añadir Sección',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
                ElevatedButton.icon(
                  onPressed: _pickAndUploadFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Subir PDF desde dispositivo'),
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
                            id: widget.initialSection?.id ?? '',
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
                      child: Text(isEditing ? 'Actualizar sección' : 'Añadir sección'),
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