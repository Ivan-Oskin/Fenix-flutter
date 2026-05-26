import 'package:flutter/material.dart';
import 'package:fenix/model/profile.dart';
import 'package:fenix/repository/profile_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fenix/view/auth_screen.dart'; // ← Укажи правильный путь к AuthScreen

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepository _repository = ProfileRepository();
  final _storage = const FlutterSecureStorage();

  Profile? profile;
  bool _isLoading = true;
  bool _isSaving = false;
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
        _surnameController = TextEditingController(text: profile?.surname ?? '');
        _patronymicController = TextEditingController(text: profile?.patronymic ?? '');

        _isLoading = false;
      });

      _nameController.addListener(_checkForChanges);
      _surnameController.addListener(_checkForChanges);
      _patronymicController.addListener(_checkForChanges);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить профиль')),
      );
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

  Future<void> _saveProfile() async {
    if (profile == null) return;

    setState(() => _isSaving = true);

    try {
      final updatedProfile = Profile(
        id: profile!.id,
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        patronymic: _patronymicController.text.trim(),
      );

      await _repository.save(updatedProfile);

      setState(() {
        profile = updatedProfile;
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профиль успешно сохранён'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка при сохранении профиля'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    try {
      await _storage.delete(key: 'jwt_token'); // Удаляем токен

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false, // Удаляем все предыдущие экраны
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при выходе')),
      );
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
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

            // Кнопка "Сохранить"
            if (_hasChanges)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC67C4E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
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

            // Кнопка "Выход"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Выйти из аккаунта",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
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