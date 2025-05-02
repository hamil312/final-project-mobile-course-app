import 'package:flutter/material.dart';
import 'package:final_project/models/course.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('General Information', [
              _buildInfoRow('id', course.id),
              _buildInfoRow('Name', course.name),
              _buildInfoRow('Description', course.description),
            ]),
            const SizedBox(height: 16.0),
            _buildInfoCard('Aditional Data', [
              for (var entry in course.themes)
                _buildInfoRow('Tema', entry),
              for (var entry in course.sections)
                _buildInfoCard(
                  entry.name,
                  [
                    _buildInfoRow('id', entry.id),
                    _buildInfoRow('Name', entry.name),
                    _buildInfoRow('Description', entry.description),
                      for (var material in entry.materials)
                        _buildInfoRow('Material', material.url),
                  ],
                ),
            ]),
          ],
        ),
      ),
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
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
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
