import 'package:appwrite/appwrite.dart';
import 'package:final_project/core/constants/appwrite_constants.dart';
import 'package:final_project/models/course_material.dart';

class CourseMaterialRepository {
  final Databases databases;
  static const String collectionId = '68065fe9000045205d3b';

  CourseMaterialRepository(this.databases);

  Future<CourseMaterial> createCourseMaterial(CourseMaterial courseMaterial) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: courseMaterial.toJson(),
      );

      return CourseMaterial.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CourseMaterial>> getCourseMaterials(String sectionId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: [Query.equal('sectionId', sectionId)],
      );

      return response.documents.map((doc) => CourseMaterial.fromJson(doc.data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCourseMaterial(String id) async {
    try {
      await databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: id,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<CourseMaterial> updateCourseMaterial(CourseMaterial courseMaterial) async {
    try {
      final response = await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: courseMaterial.id,
        data: courseMaterial.toJson(),
      );

      return CourseMaterial.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}