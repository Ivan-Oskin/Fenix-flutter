import 'package:flutter/material.dart';
import 'package:fenix/model/profile.dart'; // ← подкорректируй путь
import 'package:fenix/repository/profile_repository.dart'; // ← подкорректируй путь

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepository _repository = ProfileRepository();

  Profile? profile;
  bool _isLoading = true;
  bool _hasChanges = false;

  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _patronymicController;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final loadedProfile = await _repository.get();
      setState(() {
        profile = loadedProfile;

        _nameController = TextEditingController(text: profile?.name ?? '');
        _surnameController = TextEditingController(
          text: profile?.surname ?? '',
        );
        _patronymicController = TextEditingController(
          text: profile?.patronymic ?? '',
        );

        _isLoading = false;
      });

      // Слушаем изменения
      _nameController.addListener(_checkForChanges);
      _surnameController.addListener(_checkForChanges);
      _patronymicController.addListener(_checkForChanges);
    } catch (e) {
      setState(() => _isLoading = false);
      // Можно добавить обработку ошибки
    }
  }

  void _checkForChanges() {
    if (profile == null) return;

    final hasChanges =
        _nameController.text.trim() != (profile?.name ?? '').trim() ||
        _surnameController.text.trim() != (profile?.surname ?? '').trim() ||
        _patronymicController.text.trim() != (profile?.patronymic ?? '').trim();

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Профиль"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF484C52),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Welcome блок
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 330,
                        child: Text(
                          "Профиль",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'inter',
                            color: const Color(0xFF484C52),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Информация
                  SizedBox(
                    width: 351,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 20,
                      children: [
                        _buildField("Имя", _nameController),
                        _buildField("Фамилия", _surnameController),
                        _buildField("Отчество", _patronymicController),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Кнопка "Сохранить" — появляется только при изменениях
                  if (_hasChanges)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Пока без функционала
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC67C4E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Сохранить",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return SizedBox(
      width: 351,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("$label:", style: const TextStyle(color: Color(0xBF484C52))),
          SizedBox(
            width: 220,
            height: 40,
            child: TextField(
              controller: controller,
              cursorColor: const Color(0xFFC67C4E),
              style: const TextStyle(color: Color(0xBF484C52)),
              decoration: InputDecoration(
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFC67C4E)),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xBF484C52)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
