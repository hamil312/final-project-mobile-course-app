import 'package:final_project/repositories/auth_repository.dart';
import 'package:get/get.dart';

import 'package:final_project/models/user.dart';
import 'package:final_project/repositories/user_repository.dart';

class UserController extends GetxController {
  final UserRepository repository;
  final AuthRepository authRepository;

  UserController({required this.repository, required this.authRepository});

  final RxList<User> users = <User>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final userId = await authRepository.getCurrentUserId();
      if (userId == null) throw Exception('Sesión no iniciada');
      final fetchedUsers = await repository.getUsers(userId);
      users.assignAll(fetchedUsers);
    } catch (e) {
      error.value = e.toString();
      users.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addUser(
    User user,
  ) async {
    try {
      isLoading.value = true;
      error.value = '';

      final userId = await authRepository.getCurrentUserId();
      if (userId == null) throw Exception('No hay sesión activa');

      final createdUser = await repository.createUser(
        user.copyWith(id: '', userId: userId),
      );

      users.add(createdUser);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      error.value = '';
      isLoading.value = true;

      await repository.deleteUser(id);

      users.removeWhere((user) => user.id == id);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> updateUser(String userId, User user) async {
    try {
      final updatedUser = await repository.updateUser(userId, user);
      final index = users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        users[index] = updatedUser;
      }
    } catch (e) {
      error.value = e.toString();
    }
  }
}
