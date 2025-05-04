import 'package:final_project/pages/home_page.dart';
import 'package:final_project/pages/login_page.dart';
import 'package:final_project/repositories/auth_repository.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  AuthController(this._authRepository);

  Future<String?> getUserId() async {
    return await _authRepository.getCurrentUserId();
  }

  Future<bool> checkAuth() async {
    isLoading.value = true;
    try {
      return await _authRepository.isLoggedIn();
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    error.value = '';

    try {
      await _authRepository.login(email: email, password: password);
      Get.offAll(() => HomePage());
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String name) async {
    isLoading.value = true;
    error.value = '';

    try {
      await _authRepository.createAccount(
        email: email,
        password: password,
        name: name,
      );

      await login(email, password);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      Get.offAll(() => LoginPage());
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<String?> getCurrentUserRole() async {
    try {
      final userId = await _authRepository.getCurrentUserId();
      if (userId == null) return null;

      final role = await _authRepository.getUserRole(userId);
      return role;
    } catch (e) {
      error.value = 'Error al obtener el rol: $e';
      return null;
    }
  }
}