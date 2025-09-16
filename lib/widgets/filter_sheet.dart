// lib/widgets/filter_sheet.dart

import 'package:flutter/material.dart';

// Bu sınıf, filtre değerlerini bir arada tutmak ve
// widget'lar arasında kolayca taşımak için kullanılır.
class FilterValues {
  final String gender;
  final RangeValues ageRange;

  FilterValues({required this.gender, required this.ageRange});
}

class FilterSheet extends StatefulWidget {
  final FilterValues initialFilters;

  const FilterSheet({super.key, required this.initialFilters});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String _selectedGender;
  late RangeValues _currentAgeRange;

  final Map<String, String> _genderOptions = {
    'all': 'Herkes',
    'male': 'Erkek',
    'female': 'Kadın',
  };

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialFilters.gender;
    _currentAgeRange = widget.initialFilters.ageRange;
  }

  void _applyFilters() {
    final newFilters = FilterValues(
      gender: _selectedGender,
      ageRange: _currentAgeRange,
    );
    // Seçilen yeni filtreleri bir önceki ekrana geri gönder
    Navigator.of(context).pop(newFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filtrele', style: Theme.of(context).textTheme.headlineSmall),
          const Divider(height: 32),

          // Cinsiyet Filtresi
          _buildSectionTitle('Cinsiyet'),
          Wrap(
            spacing: 8.0,
            children: _genderOptions.entries.map((entry) {
              return ChoiceChip(
                label: Text(entry.value),
                selected: _selectedGender == entry.key,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedGender = entry.key;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Yaş Aralığı Filtresi
          _buildSectionTitle(
              'Yaş Aralığı (${_currentAgeRange.start.round()} - ${_currentAgeRange.end.round()})'),
          RangeSlider(
            values: _currentAgeRange,
            min: 18,
            max: 65,
            divisions: 47, // 65 - 18
            labels: RangeLabels(
              _currentAgeRange.start.round().toString(),
              _currentAgeRange.end.round().toString(),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentAgeRange = values;
              });
            },
          ),
          const SizedBox(height: 32),

          // Uygula Butonu
          ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('Filtreleri Uygula'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
