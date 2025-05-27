import 'package:appwrite/appwrite.dart';
import 'package:final_project/core/constants/appwrite_constants.dart';
import 'package:final_project/models/enrollment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnrollmentRepository {
  final Databases databases;
  static final String collectionId = dotenv.env['COLLECTION_ENROLLMENTS']!;

  EnrollmentRepository(this.databases);

  Future<Enrollment> createEnrollment(Enrollment enrollment) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: enrollment.toJson(),
      );

      return Enrollment.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Enrollment>> getEnrollments(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('userId', userId),
        ],
      );

      return response.documents
          .map((doc) => Enrollment.fromJson(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEnrollment(String id) async {
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

  Future<Enrollment> updateEnrollment(String id, Enrollment enrollment) async {
    try {
      final response = await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: id,
        data: enrollment.toJson(),
      );
      return Enrollment.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
