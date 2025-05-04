import 'package:final_project/controllers/auth_controller.dart';
import 'package:final_project/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:final_project/models/user.dart';

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final userController = Get.find<UserController>();
  final RxString selectedRole = 'user'.obs;

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) return 'Campo requerido';
                  if (!GetUtils.isEmail(value)) return 'Email inválido';
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Campo requerido';
                  if (value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selecciona tu rol'),
                  ListTile(
                    title: const Text('Usuario'),
                    leading: Radio<String>(
                      value: 'user',
                      groupValue: selectedRole.value,
                      onChanged: (value) {
                        if (value != null) selectedRole.value = value;
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Admin'),
                    leading: Radio<String>(
                      value: 'admin',
                      groupValue: selectedRole.value,
                      onChanged: (value) {
                        if (value != null) selectedRole.value = value;
                      },
                    ),
                  ),
                ],
              )),
              SizedBox(height: 20),
              Obx(() {
                if (authController.isLoading.value) {
                  return CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authController.register(
                        _emailController.text,
                        _passwordController.text,
                        _nameController.text,
                      );

                      if (authController.error.value.isNotEmpty) return;

                      final userId = await authController.getUserId();
                      if (userId != null) {
                        final user = User(id: '', role: selectedRole.value, userId: userId);
                        await userController.addUser(user);
                      }
                    }
                  },
                  child: Text('Registrarse'),
                );
              }),
              Obx(() {
                if (authController.error.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      authController.error.value,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}