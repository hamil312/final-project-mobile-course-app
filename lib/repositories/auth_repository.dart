import 'package:appwrite/appwrite.dart';
import 'package:final_project/core/constants/appwrite_constants.dart';

class AuthRepository {
  final Account account;

  AuthRepository(this.account);

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
  Future<void> addUserToTeam(String role) async {
    try {
      final user = await account.get();
      print('user email: ${user.email}');
      print('teamId: ${AppwriteConstants.teamId}');
      
      final teamId = AppwriteConstants.teamId;
      final teamRole = role == 'admin' ? 'admin' : 'usuario';
      final teams = Teams(account.client);

      await teams.createMembership(
        teamId: teamId,
        email: user.email,
        roles: [teamRole],
        url: 'http://localhost:57856/', // cambia esto por una URL válida
        name: user.name,
      );

      print('Membership creation request sent.');
    } catch (e) {
      print('Error al crear membresía: $e');
      rethrow;
    }
  }
}