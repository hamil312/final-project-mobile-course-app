import 'package:flutter/material.dart';
import 'package:final_project/models/course.dart';
import 'package:final_project/pages/course_detail_page.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final String? userId;
  final bool isAdmin;
  final List<String> enrolledCourseIds;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.userId,
    required this.isAdmin,
    required this.enrolledCourseIds,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            course.name.substring(0, 1),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          course.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Text(course.name),
            const SizedBox(height: 4.0),
            Text(course.description),
          ],
        ),
        onTap: onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailPage(
                    course: course,
                    userId: userId,
                    isAdmin: isAdmin,
                    enrolledCourseIds: enrolledCourseIds,
                  ),
                ),
              );
            },
      ),
    );
  }
}