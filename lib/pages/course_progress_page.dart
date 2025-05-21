import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:get/get.dart';
import 'package:final_project/controllers/enrollment_controller.dart';

class CourseProgressPage extends StatelessWidget {
  final String courseId;

  const CourseProgressPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final enrollmentController = Get.find<EnrollmentController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Progreso del Curso')),
      body: Obx(() {
        final enrollment = enrollmentController.enrollments
            .firstWhereOrNull((e) => e.courseId == courseId);

        if (enrollment == null) {
          return const Center(child: Text('No estás inscrito en este curso.'));
        }

        return FutureBuilder<int>(
          future: enrollmentController.getTotalMaterialsForCourse(courseId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final totalMaterials = snapshot.data ?? 0;
            print('Total de materiales: $totalMaterials');
            final completed = enrollment.calculateCompletionRate(totalMaterials).toDouble();
            final remaining = (100.0 - completed).clamp(0.0, 100.0);

            final dataMap = {
              "Completado": completed,
              "Faltante": remaining,
            };

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: PieChart(
                  dataMap: dataMap,
                  chartType: ChartType.ring,
                  animationDuration: const Duration(milliseconds: 800),
                  chartRadius: MediaQuery.of(context).size.width / 2.2,
                  legendOptions: const LegendOptions(
                    showLegendsInRow: true,
                    legendPosition: LegendPosition.bottom,
                  ),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValuesInPercentage: true,
                    showChartValues: true,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}