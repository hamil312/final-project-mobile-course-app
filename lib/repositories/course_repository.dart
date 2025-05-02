import 'package:appwrite/appwrite.dart';
import 'package:final_project/core/constants/appwrite_constants.dart';
import 'package:final_project/models/course.dart';

class CourseRepository {
  final Databases databases;
  static const String collectionId = '680661ad000b25f4a2cb';

  CourseRepository(this.databases);

  Future<Course> createCourse(Course course) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: course.toJson(),
      );

      return Course.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Course>> getCourses(String authorId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('authorId', authorId),
        ],
      );

      return response.documents
          .map((doc) => Course.fromJson(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCourse(String id) async {
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

  Future<Course> updateCourse(String authorId,Course course) async {
    try {
      final response = await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: authorId,
        data: course.toJson(),
      );

      return Course.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
