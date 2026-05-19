import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Авторизация
              const Text(
                'Авторизация',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // 2. logo.png
              Image.asset(
                'assets/images/reg/logo.png',
                width: 110,
                height: 110,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 60),

              // 3. Поле Email
              CustomTextField(label: 'Email', width: 320),
              const SizedBox(height: 30),

              // 4. Поле Пароль
              CustomTextField(label: 'Пароль', width: 320),

              const SizedBox(height: 70),
              TextButton(
                onPressed: () {

                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Войти',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // 5. Кнопка «регистрация»
              TextButton(
                onPressed: () {
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'регистрация',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

  const CustomTextField({
    super.key,
    required this.label,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        cursorColor: const Color(0xFFC67C4E),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
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
