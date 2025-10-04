// lib/screens/complete_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/navigation_service.dart';
import 'loading_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _birthCityController = TextEditingController();

  DateTime? _selectedBirthDate;
  TimeOfDay? _selectedBirthTime;
  String? _selectedGenderValue;

  final Map<String, String> _genderOptions = const {
    'female': 'Kadın',
    'male': 'Erkek',
  };

  @override
  void dispose() {
    _birthCityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedBirthTime ?? const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthTime) {
      setState(() => _selectedBirthTime = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBirthDate == null || _selectedBirthTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen doğum tarihi ve saatini eksiksiz seçin.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoading) return;

    final profileData = {
      'gender': _selectedGenderValue!,
      'birth_city': _birthCityController.text.trim(),
      'birth_date': DateFormat('yyyy-MM-dd').format(_selectedBirthDate!),
      'birth_time':
          '${_selectedBirthTime!.hour.toString().padLeft(2, '0')}:${_selectedBirthTime!.minute.toString().padLeft(2, '0')}',
    };

    try {
      final success =
          await authProvider.updateProfile(profileData: profileData);

      if (mounted && success) {
        // YENİ VE KESİN ÇÖZÜM:
        // Profil güncellendikten sonra, bekleme mantığını çalıştırıyoruz.
        // Bu, LoadingScreen'i güncel verilerle ana ekrana yönlendirecektir.
        NavigationService.navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoadingScreen()),
          (route) => false,
        );

        // Bu kısım, artık LoadingScreen içinde polling yapıldığı için kaldırıldı.
        // await authProvider.refreshUser();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ??
                'Profil tamamlanamadı. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: AbsorbPointer(
              absorbing: isLoading,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Son Bir Adım!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yıldız haritanı oluşturmak için bu bilgilere ihtiyacımız var.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGenderValue,
                    decoration: const InputDecoration(labelText: 'Cinsiyetin'),
                    items: _genderOptions.entries.map((entry) {
                      return DropdownMenuItem<String>(
                          value: entry.key, child: Text(entry.value));
                    }).toList(),
                    onChanged: (newValue) =>
                        setState(() => _selectedGenderValue = newValue),
                    validator: (value) =>
                        value == null ? 'Lütfen cinsiyetini seç.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthCityController,
                    decoration:
                        const InputDecoration(labelText: 'Doğum Şehrin'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Lütfen doğum şehrini gir.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDateTimePickers(),
                  const SizedBox(height: 32),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _saveProfile,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('HARİTAMI OLUŞTUR VE BAŞLA'),
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            readOnly: true,
            onTap: _selectDate,
            decoration: InputDecoration(
                labelText: 'Doğum Tarihin',
                hintText: _selectedBirthDate != null
                    ? DateFormat('dd.MM.yyyy').format(_selectedBirthDate!)
                    : 'Seçiniz',
                suffixIcon: const Icon(Icons.calendar_today)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            readOnly: true,
            onTap: _selectTime,
            decoration: InputDecoration(
                labelText: 'Doğum Saatin',
                hintText: _selectedBirthTime != null
                    ? _selectedBirthTime!.format(context)
                    : 'Seçiniz',
                suffixIcon: const Icon(Icons.access_time)),
          ),
        ),
      ],
    );
  }
}
