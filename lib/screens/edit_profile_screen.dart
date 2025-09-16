// Lütfen bu kodu kopyalayıp lib/screens/edit_profile_screen.dart dosyasının içine yapıştırın.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
// import '../models/app_user.dart'; // GEREKSİZ OLDUĞU İÇİN KALDIRILDI
import '../models/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _bioController;
  late TextEditingController _birthCityController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final UserProfile? profile = context.read<AuthProvider>().user?.profile;

    _bioController = TextEditingController(text: profile?.bio ?? '');
    _birthCityController =
        TextEditingController(text: profile?.birthCity ?? '');
    _selectedDate = profile?.birthDate;

    if (profile?.birthTime != null && profile!.birthTime!.contains(':')) {
      final parts = profile.birthTime!.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _birthCityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
        context: context,
        builder: (bc) => SafeArea(
                child: Wrap(children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeriden Seç'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Kamera ile Çek'),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  }),
            ])));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoading) return;

    final profileData = {
      'bio': _bioController.text.trim(),
      'birth_city': _birthCityController.text.trim(),
      if (_selectedDate != null)
        'birth_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      if (_selectedTime != null)
        'birth_time':
            '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
    };

    final success = await authProvider.updateProfile(
      profileData: profileData,
      avatarFile: _selectedImage,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Profil başarıyla güncellendi! Astroloji verileriniz arka planda hesaplanıyor...'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(authProvider.errorMessage ?? 'Profil güncellenemedi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final String? avatarUrl = user?.profile.avatar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        actions: [
          if (authProvider.isLoading)
            const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white)))
          else
            IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveProfile,
                tooltip: 'Kaydet')
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(avatarUrl),
              const SizedBox(height: 32),
              const Text("Temel Bilgiler",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple)),
              const Divider(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                    labelText: 'Hakkında', hintText: 'Kendinden bahset...'),
                maxLines: 5,
                maxLength: 500,
              ),
              const SizedBox(height: 24),
              const Text("Astroloji Bilgileri",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple)),
              const Divider(),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Doğum Tarihi',
                  hintText: _selectedDate == null
                      ? 'Tarih seçin'
                      : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Doğum Saati',
                  hintText: _selectedTime == null
                      ? 'Saat seçin'
                      : _selectedTime!.format(context),
                  suffixIcon: const Icon(Icons.access_time),
                ),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _birthCityController,
                decoration: const InputDecoration(
                    labelText: 'Doğum Şehri', hintText: 'Örn: İstanbul'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen doğum şehrinizi girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Text(
                  "Doğum haritanızın doğru hesaplanabilmesi için bu bilgilerin girilmesi gereklidir.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    return Center(
        child: Stack(children: [
      CircleAvatar(
        radius: 60,
        backgroundImage: _selectedImage != null
            ? FileImage(_selectedImage!)
            : (avatarUrl != null ? NetworkImage(avatarUrl) : null),
        child: _selectedImage == null && avatarUrl == null
            ? const Icon(Icons.person, size: 60)
            : null,
      ),
      Positioned(
          bottom: 0,
          right: 0,
          child: Material(
              color: Theme.of(context).primaryColor,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: _showImagePickerOptions))),
    ]));
  }
}
