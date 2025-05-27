import 'package:appwrite/appwrite.dart';
import 'package:final_project/core/constants/appwrite_constants.dart';
import 'package:final_project/models/section.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SectionRepository {
  final Databases databases;
  static final String collectionId = dotenv.env['COLLECTION_SECTIONS']!;

  SectionRepository(this.databases);

  Future<Section> createSection(Section section) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: section.toJson(),
      );

      return Section.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Section>> getSections() async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
      );

      return response.documents
          .map((doc) => Section.fromJson(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSection(String id) async {
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

  Future<Section> updateSection(Section section) async {
    try {
      final response = await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: section.id,
        data: section.toJson(),
      );

      return Section.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Section>> getSectionsByCourse(String courseId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: [Query.equal('courseId', courseId)],
      );

      return response.documents.map((doc) => Section.fromJson(doc.data)).toList();
    } catch (e) {
      rethrow;
    }
  }
}