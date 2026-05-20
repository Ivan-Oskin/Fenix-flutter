import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fenix/model/profile.dart';
import 'package:fenix/repository/profile_repository.dart';
import 'package:fenix/main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  final _storage = const FlutterSecureStorage();

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://llvvv.ru:8080/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token']; // подкорректируй ключ, если отличается

        // Получаем профиль
        final profileResponse = await http.get(
          Uri.parse('http://llvvv.ru:8080/api/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (profileResponse.statusCode == 200) {
          final Map<String, dynamic> profileJson = jsonDecode(profileResponse.body);

          // ← Вот здесь исправление
          final profile = Profile.fromMap(profileJson);

          // Сохраняем через твой репозиторий
          await ProfileRepository().save(profile);

          // Сохраняем токен в безопасное хранилище
          await _storage.write(key: 'jwt_token', value: token);

          // Переходим на главный экран
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainWidget()),
            );
          }
        } else {
          setState(() => _errorMessage = 'Не удалось получить профиль');
        }
      } else {
        setState(() => _errorMessage = 'Неверный email или пароль');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка подключения к серверу');
      print('Login error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
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
                'Авторизация',
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
              const SizedBox(height: 60),

              CustomTextField(
                label: 'Email',
                width: 320,
                controller: _emailController,
              ),
              const SizedBox(height: 30),

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
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 40),

              SizedBox(
                width: 320,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC67C4E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Войти',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              TextButton(
                onPressed: () {
                  // Переход на регистрацию
                },
                child: const Text(
                  'регистрация',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final double width;
  final TextEditingController? controller;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.label,
    required this.width,
    this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        cursorColor: const Color(0xFFC67C4E),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          floatingLabelStyle: const TextStyle(
            color: Color(0xFFC67C4E),
            fontSize: 16,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFC67C4E), width: 1.8),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFC67C4E), width: 2.2),
          ),
          contentPadding: const EdgeInsets.only(bottom: 8),
        ),
      ),
    );
  }
}