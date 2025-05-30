import 'package:appwrite/appwrite.dart';
import 'package:final_project/core/constants/appwrite_constants.dart';
import 'package:final_project/models/course.dart';
import 'package:final_project/models/course_material.dart';
import 'package:final_project/models/section.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CourseRepository {
  final Databases databases;
  static final String collectionId = dotenv.env['COLLECTION_COURSES']!;
  static final String sectionsCollectionId = dotenv.env['COLLECTION_SECTIONS']!;
  static final String materialsCollectionId = dotenv.env['COLLECTION_MATERIALS']!;

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

  Future<List<Course>> getAllCourses() async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
      );

      return response.documents
          .map((doc) => Course.fromJson(doc.data))
          .toList();
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

  Future<List<Course>> getCoursesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: [Query.equal('\$id', ids)],
      );

      return response.documents.map((doc) => Course.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Error al obtener cursos por IDs: $e');
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

  Future<Course> updateCourse(Course course) async {
    try {
      final response = await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: course.id,
        data: course.toJson(),
      );
      return Course.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Section> createSection(Section section) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: sectionsCollectionId,
        documentId: ID.unique(),
        data: section.toJson(),
      );
      return Section.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  Future<CourseMaterial> createMaterial(CourseMaterial material) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: materialsCollectionId,
        documentId: ID.unique(),
        data: material.toJson(),
      );
      return CourseMaterial.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Section>> getSectionsByCourseId(String courseId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: sectionsCollectionId,
        queries: [
          Query.equal('courseId', courseId),
        ],
      );

      return response.documents
          .map((doc) => Section.fromJson(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CourseMaterial>> getMaterialsBySectionId(String sectionId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: materialsCollectionId,
        queries: [
          Query.equal('sectionId', sectionId),
        ],
      );

      return response.documents
          .map((doc) => CourseMaterial.fromJson(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSection(String sectionId) async {
    try {
      await databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: sectionsCollectionId,
        documentId: sectionId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMaterial(String materialId) async {
    try {
      await databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: materialsCollectionId,
        documentId: materialId,
      );
    } catch (e) {
      rethrow;
    }
  }
  Future<List<CourseMaterial>> getMaterialsForCourse(String courseId) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: materialsCollectionId,
      queries: [
        Query.equal('courseId', courseId),
      ],
    );

    return response.documents
        .map((doc) => CourseMaterial.fromJson(doc.data))
        .toList();
  }
}
