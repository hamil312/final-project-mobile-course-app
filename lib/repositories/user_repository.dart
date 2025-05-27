import 'package:appwrite/appwrite.dart';
import 'package:final_project/core/constants/appwrite_constants.dart';
import 'package:final_project/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserRepository {
  final Databases databases;
  static final String collectionId = dotenv.env['COLLECTION_USERS']!;

  UserRepository(this.databases);

  Future<User> createUser(User user) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: user.toJson(),
      );

      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getUsers(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('userId', userId),
        ],
      );

      return response.documents
          .map((doc) => User.fromJson(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
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

  Future<User> updateUser(String userId, User user) async {
    try {
      final response = await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: userId,
        data: user.toJson(),
      );
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

}
