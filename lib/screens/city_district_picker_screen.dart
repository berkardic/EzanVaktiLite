import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/prayer_time_viewmodel.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../constants/strings.dart';
import '../models/diyanet_city.dart';
import '../models/diyanet_district.dart';

class CityDistrictPickerScreen extends StatefulWidget {
  const CityDistrictPickerScreen({super.key});

  @override
  State<CityDistrictPickerScreen> createState() => _CityDistrictPickerScreenState();
}

class _CityDistrictPickerScreenState extends State<CityDistrictPickerScreen> {
  bool _isDistrictStep = false;
  String _searchCity = '';
  String _searchDistrict = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimeViewModel>(
      builder: (context, vm, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.sheetBg(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Navigation bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    if (_isDistrictStep)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDistrictStep = false;
                            _searchDistrict = '';
                          });
                        },
                        child: Row(
                          children: [
                            Icon(AppIcons.chevronLeft, color: AppTheme.textPrimary(context), size: 20),
                            Text(
                              AppStrings.back(vm.language),
                              style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(width: 60),
                    const Spacer(),
                    Text(
                      _isDistrictStep
                          ? AppStrings.selectDistrict(vm.language)
                          : AppStrings.selectProvince(vm.language),
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        AppStrings.close(vm.language),
                        style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Step indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    _stepCircle(context, '1', 'İl', true),
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 18),
                        color: _isDistrictStep
                            ? AppColors.gold
                            : AppTheme.sheetSecondary(context).withOpacity(0.3),
                      ),
                    ),
                    _stepCircle(context, '2', 'İlçe', _isDistrictStep),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Content
              Expanded(
                child: _isDistrictStep
                    ? _districtListView(vm)
                    : _cityListView(vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cityListView(PrayerTimeViewModel vm) {
    final filtered = _filteredCities(vm);

    return Column(
      children: [
        _searchField(
          AppStrings.searchCity(vm.language),
          _searchCity,
          (val) => setState(() => _searchCity = val),
        ),
        if (vm.isLoadingCities) ...[
          const Spacer(),
          const CircularProgressIndicator(color: AppColors.gold),
          const SizedBox(height: 12),
          Text(
            AppStrings.citiesLoading(vm.language),
            style: TextStyle(color: AppTheme.sheetSecondary(context), fontSize: 14),
          ),
          const Spacer(),
        ] else if (vm.cities.isEmpty) ...[
          const Spacer(),
          Icon(AppIcons.wifiOff, size: 36, color: AppTheme.sheetSecondary(context).withOpacity(0.6)),
          const SizedBox(height: 12),
          Text(
            AppStrings.couldNotLoadCities(vm.language),
            style: TextStyle(color: AppTheme.sheetSecondary(context)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => vm.loadCitiesAndRestore(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenButton,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppStrings.retry(vm.language)),
          ),
          const Spacer(),
        ] else
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final city = filtered[i];
                final name = vm.language == 'tr' ? city.sehirAdi : city.sehirAdiEn;
                final selected = city.id == vm.selectedCity?.id;

                return ListTile(
                  title: Text(name, style: TextStyle(color: AppTheme.textPrimary(context))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected)
                        const Icon(AppIcons.check, color: AppColors.greenAccent, size: 18),
                      const SizedBox(width: 8),
                      Icon(AppIcons.chevronRight, size: 16,
                          color: AppTheme.textPrimary(context).withOpacity(0.3)),
                    ],
                  ),
                  tileColor: AppTheme.sheetItemBg(context),
                  onTap: () async {
                    try {
                      await vm.selectCity(city);
                    } catch (e) {
                      debugPrint('selectCity error: $e');
                    }
                    if (mounted) {
                      setState(() {
                        _isDistrictStep = true;
                        _searchCity = '';
                      });
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _districtListView(PrayerTimeViewModel vm) {
    final filtered = _filteredDistricts(vm);

    return Column(
      children: [
        _searchField(
          AppStrings.searchDistrict(vm.language),
          _searchDistrict,
          (val) => setState(() => _searchDistrict = val),
        ),
        if (vm.isLoadingDistricts) ...[
          const Spacer(),
          const CircularProgressIndicator(color: AppColors.gold),
          const SizedBox(height: 12),
          Text(
            AppStrings.districtsLoading(vm.language),
            style: TextStyle(color: AppTheme.sheetSecondary(context), fontSize: 14),
          ),
          const Spacer(),
        ] else if (vm.districts.isEmpty) ...[
          const Spacer(),
          Icon(Icons.wifi_off, size: 32, color: AppTheme.sheetSecondary(context).withOpacity(0.6)),
          const SizedBox(height: 12),
          Text(
            vm.errorMessage ?? AppStrings.noDistricts(vm.language),
            style: TextStyle(color: AppTheme.sheetSecondary(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => vm.loadDistricts(vm.selectedCity!),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppStrings.retry(vm.language)),
          ),
          const Spacer(),
        ] else
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final district = filtered[i];
                final name = vm.language == 'tr' ? district.ilceAdi : district.ilceAdiEn;
                final selected = district.id == vm.selectedDistrict?.id;

                return ListTile(
                  title: Text(name, style: TextStyle(color: AppTheme.textPrimary(context))),
                  trailing: selected
                      ? const Icon(AppIcons.check, color: AppColors.greenAccent, size: 18)
                      : null,
                  tileColor: AppTheme.sheetItemBg(context),
                  onTap: () async {
                    await vm.selectDistrict(district);
                    if (mounted) Navigator.pop(context);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _searchField(String placeholder, String value, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.sheetItemBg(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(AppIcons.search, size: 18, color: AppTheme.sheetSecondary(context)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: TextStyle(color: AppTheme.textPrimary(context)),
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(color: AppTheme.sheetSecondary(context)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepCircle(BuildContext context, String num, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.greenButton : AppTheme.pickerBg(context),
          ),
          child: Center(
            child: Text(
              num,
              style: TextStyle(
                color: active ? Colors.white : AppTheme.textPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.sheetSecondary(context),
          ),
        ),
      ],
    );
  }

  List<DiyanetCity> _filteredCities(PrayerTimeViewModel vm) {
    if (_searchCity.isEmpty) return vm.cities;
    final q = vm.normalize(_searchCity);
    return vm.cities.where((c) =>
        vm.normalize(c.sehirAdi).contains(q) ||
        vm.normalize(c.sehirAdiEn).contains(q)).toList();
  }

  List<DiyanetDistrict> _filteredDistricts(PrayerTimeViewModel vm) {
    if (_searchDistrict.isEmpty) return vm.districts;
    final q = vm.normalize(_searchDistrict);
    return vm.districts.where((d) =>
        vm.normalize(d.ilceAdi).contains(q) ||
        vm.normalize(d.ilceAdiEn).contains(q)).toList();
  }
}
