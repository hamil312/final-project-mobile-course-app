import 'package:appwrite/appwrite.dart';
import 'package:final_project/core/constants/appwrite_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepository {
  final Account account;
  final Databases databases;

  AuthRepository(this.account, this.databases);

  Future<String?> getCurrentUserId() async {
    try {
      final user = await account.get();
      return user.$id;
    } catch (e) {
      return null;
    }
  }

  Future<void> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      await account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getUserRole(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: dotenv.env['COLLECTION_USERS']!,
        queries: [Query.equal('userId', userId)],
      );

      if (response.documents.isNotEmpty) {
        final role = response.documents.first.data['role'];
        return role;
      }
      return null;
    } catch (e) {
      print('Error al obtener el rol del usuario: $e');
      return null;
    }
  }
}