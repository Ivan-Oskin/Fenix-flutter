import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fenix/main.dart';
import 'package:fenix/view/auth_screen.dart';
import 'package:fenix/model/profile.dart';
import 'package:fenix/repository/profile_repository.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  final _storage = const FlutterSecureStorage();
  final _profileRepository = ProfileRepository();

  Future<void> _register() async {
    // Валидация
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.trim().isEmpty ||
        _surnameController.text.trim().isEmpty) {
      setState(
        () => _errorMessage = 'Пожалуйста, заполните все обязательные поля',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String username = _emailController.text.trim();
      final String password = _passwordController.text;
      final String name = _nameController.text.trim();
      final String surname = _surnameController.text.trim();
      final String patronymic = _patronymicController.text.trim();

      // 1. Регистрация пользователя
      final registerResponse = await http.post(
        Uri.parse('http://llvvv.ru:8080/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "password": password,
          "name": name,
          "surname": surname,
          "patronymic": patronymic,
          "type": "listener",
        }),
      );

      if (registerResponse.statusCode != 200 &&
          registerResponse.statusCode != 201) {
        setState(
          () => _errorMessage =
              'Ошибка регистрации (${registerResponse.statusCode})',
        );
        return;
      }

      // 2. Авторизация и получение токена
      final loginResponse = await http.post(
        Uri.parse('http://llvvv.ru:8080/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (loginResponse.statusCode != 200) {
        setState(() => _errorMessage = 'Не удалось войти после регистрации');
        return;
      }

      final loginData = jsonDecode(loginResponse.body);
      final String token = loginData['token']; // ← измени ключ, если отличается

      // Сохраняем токен
      await _storage.write(key: 'jwt_token', value: token);

      // 3. Получаем профиль с сервера
      final profileResponse = await http.get(
        Uri.parse('http://llvvv.ru:8080/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (profileResponse.statusCode == 200) {
        final Map<String, dynamic> profileJson = jsonDecode(
          profileResponse.body,
        );
        final profile = Profile.fromMap(profileJson);

        // Сохраняем профиль в локальную БД
        await _profileRepository.save(profile);
      } else {
        print(
          'Не удалось получить профиль после регистрации: ${profileResponse.statusCode}',
        );
        // Можно продолжить, т.к. токен уже сохранён
      }

      // Переход на главный экран
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainWidget()),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка подключения к серверу');
      print('Registration error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Регистрация',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              Image.asset(
                'assets/images/reg/logo.png',
                width: 110,
                height: 110,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 50),

              CustomTextField(
                label: 'Имя',
                width: 320,
                controller: _nameController,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Фамилия',
                width: 320,
                controller: _surnameController,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Отчество',
                width: 320,
                controller: _patronymicController,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Email',
                width: 320,
                controller: _emailController,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Пароль',
                width: 320,
                controller: _passwordController,
                isPassword: true,
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 40),

              SizedBox(
                width: 320,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC67C4E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Зарегистрироваться',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Уже есть аккаунт? Войти',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
