import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/prayer_time_viewmodel.dart';
import '../models/diyanet_country.dart';
import '../services/location_service.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../constants/strings.dart';
import '../widgets/banner_ad_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      AppStrings.settings(vm.language),
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          AppStrings.done(vm.language),
                          style: TextStyle(
                            color: AppTheme.accentColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // General section (ülke + dil + tema)
                    _sectionHeader(context, AppStrings.general(vm.language)),
                    _card(
                      context: context,
                      child: Column(
                        children: [
                          // Country row
                          GestureDetector(
                            onTap: () => _openCountryPicker(context, vm),
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: [
                                Icon(Icons.public_rounded,
                                    color: AppTheme.textPrimary(context), size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  AppStrings.country(vm.language),
                                  style: TextStyle(
                                      color: AppTheme.textPrimary(context), fontSize: 16),
                                ),
                                const Spacer(),
                                if (vm.isLoadingCountries)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.gold),
                                  )
                                else
                                  Text(
                                    vm.selectedCountry != null
                                        ? (vm.language == 'tr'
                                            ? vm.selectedCountry!.ulkeAdi
                                            : vm.selectedCountry!.ulkeAdiEn)
                                        : AppStrings.selectCountry(vm.language),
                                    style: TextStyle(
                                        color: AppTheme.sheetSecondary(context),
                                        fontSize: 13),
                                  ),
                                const SizedBox(width: 4),
                                Icon(AppIcons.chevronRight,
                                    size: 16,
                                    color: AppTheme.textPrimary(context).withOpacity(0.3)),
                              ],
                            ),
                          ),
                          Divider(color: AppTheme.sheetDivider(context), height: 24),
                          GestureDetector(
                            onTap: () => _openLanguagePicker(context, vm),
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: [
                                Icon(AppIcons.language,
                                    color: AppTheme.textPrimary(context), size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  AppStrings.language(vm.language),
                                  style: TextStyle(
                                      color: AppTheme.textPrimary(context), fontSize: 16),
                                ),
                                const Spacer(),
                                Text(
                                  AppStrings.languageNames[vm.language] ?? vm.language,
                                  style: TextStyle(
                                      color: AppTheme.sheetSecondary(context), fontSize: 13),
                                ),
                                const SizedBox(width: 4),
                                Icon(AppIcons.chevronRight,
                                    size: 16,
                                    color: AppTheme.textPrimary(context).withOpacity(0.3)),
                              ],
                            ),
                          ),
                          Divider(color: AppTheme.sheetDivider(context), height: 24),
                          Row(
                            children: [
                              Icon(Icons.palette_outlined,
                                  color: AppTheme.textPrimary(context), size: 20),
                              const SizedBox(width: 12),
                              Text(
                                vm.language == 'tr' ? 'Tema' : vm.language == 'ar' ? 'المظهر' : 'Theme',
                                style: TextStyle(
                                    color: AppTheme.textPrimary(context), fontSize: 16),
                              ),
                              const Spacer(),
                              _themePicker(context, vm),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Location section
                    _sectionHeader(context, AppStrings.locationPermissions(vm.language)),
                    _card(
                      context: context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _locationIcon(vm.locationAuthStatus),
                                color: _locationColor(vm.locationAuthStatus),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _locationStatusText(vm),
                                style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 16),
                              ),
                            ],
                          ),
                          if (vm.locationAuthStatus == 'denied') ...[
                            const SizedBox(height: 12),
                            _greenButton(
                              AppStrings.openSettings(vm.language),
                              () => LocationService.shared.openAppSettings(),
                            ),
                          ],
                          if (vm.locationAuthStatus == 'authorized') ...[
                            const SizedBox(height: 12),
                            _greenButton(
                              AppStrings.requestAlwaysPerm(vm.language),
                              () => LocationService.shared.requestPermission(),
                              icon: AppIcons.locationFill,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.backgroundLocationNote(vm.language),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.sheetSecondary(context).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        AppStrings.locationPermFooter(vm.language),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.sheetSecondary(context).withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notifications section
                    _sectionHeader(context, AppStrings.notifications(vm.language)),
                    ListenableBuilder(
                      listenable: vm.notificationManager,
                      builder: (context, _) {
                        return _card(
                          context: context,
                          child: Column(
                            children: List.generate(6, (i) {
                              final names = AppStrings.prayerNames(vm.language);
                              final key = AppStrings.prayerKeys[i];
                              final icon = AppIcons.prayerIcons[i];
                              final enabled = vm.notificationManager.enabledPrayers.contains(key);

                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(icon, color: AppTheme.accentColor(context), size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          names[i],
                                          style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 16),
                                        ),
                                        const Spacer(),
                                        Switch(
                                          value: enabled,
                                          onChanged: (_) => vm.notificationManager.togglePrayer(key),
                                          activeColor: AppColors.greenButton,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (i < 5)
                                    Divider(color: AppTheme.sheetDivider(context), height: 1),
                                ],
                              );
                            }),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // About section
                    _sectionHeader(context, AppStrings.about(vm.language)),
                    _card(
                      context: context,
                      child: Column(
                        children: [
                          _infoRow(
                            context,
                            AppIcons.info,
                            AppStrings.dataSource(vm.language),
                            'Diyanet İşleri Başkanlığı',
                          ),
                          Divider(color: AppTheme.sheetDivider(context), height: 1),
                          _infoRow(
                            context,
                            AppIcons.version,
                            'Version',
                            '1.0.2',
                          ),
                          Divider(color: AppTheme.sheetDivider(context), height: 1),
                          _infoRow(
                            context,
                            AppIcons.update,
                            AppStrings.updateDate(vm.language),
                            _buildDate(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openLanguagePicker(BuildContext context, PrayerTimeViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: const _LanguagePickerSheet(),
      ),
    );
  }

  void _openCountryPicker(BuildContext context, PrayerTimeViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: const _CountryPickerSheet(),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.sheetSecondary(context),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _card({required BuildContext context, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sheetItemBg(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _themePicker(BuildContext context, PrayerTimeViewModel vm) {
    final lang = vm.language;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pickerBg(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _themeOption(context, vm, Icons.brightness_auto_rounded, ThemeMode.system,
              lang == 'tr' ? 'Otomatik' : lang == 'ar' ? 'تلقائي' : 'Auto'),
          _themeOption(context, vm, Icons.dark_mode_rounded, ThemeMode.dark,
              lang == 'tr' ? 'Koyu' : lang == 'ar' ? 'داكن' : 'Dark'),
          _themeOption(context, vm, Icons.light_mode_rounded, ThemeMode.light,
              lang == 'tr' ? 'Açık' : lang == 'ar' ? 'فاتح' : 'Light'),
        ],
      ),
    );
  }

  Widget _themeOption(BuildContext context, PrayerTimeViewModel vm, IconData icon, ThemeMode mode, String label) {
    final selected = vm.themeMode == mode;
    return GestureDetector(
      onTap: () => vm.setThemeMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenButton : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? Colors.white : AppTheme.textPrimary(context), size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: selected ? Colors.white : AppTheme.textPrimary(context), fontSize: 9, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _greenButton(String text, VoidCallback onTap, {IconData? icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.greenButton,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textPrimary(context), size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.sheetSecondary(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _locationIcon(String status) {
    switch (status) {
      case 'denied': return AppIcons.locationDenied;
      case 'authorized': return AppIcons.locationAuthorized;
      default: return AppIcons.locationSearching;
    }
  }

  Color _locationColor(String status) {
    switch (status) {
      case 'denied': return Colors.red;
      case 'authorized': return AppColors.greenAccent;
      default: return Colors.orange;
    }
  }

  String _locationStatusText(PrayerTimeViewModel vm) {
    switch (vm.locationAuthStatus) {
      case 'denied': return AppStrings.locationDenied(vm.language);
      case 'authorized': return AppStrings.locationWhileUsing(vm.language);
      default: return AppStrings.locationNotAuthorized(vm.language);
    }
  }

  String _buildDate() {
    return DateTime.now().toString().split(' ').first;
  }
}

// ─── Country Picker Sheet ─────────────────────────────────────────────────────

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet();

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimeViewModel>(
      builder: (context, vm, _) {
        final lang = vm.language;
        final filtered = _filtered(vm);

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: AppTheme.sheetBg(context),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    const SizedBox(width: 60),
                    const Spacer(),
                    Text(
                      AppStrings.selectCountry(lang),
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
                        AppStrings.close(lang),
                        style: TextStyle(
                            color: AppTheme.accentColor(context), fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.sheetItemBg(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(AppIcons.search,
                          size: 18,
                          color: AppTheme.sheetSecondary(context)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _search = v),
                          style: TextStyle(color: AppTheme.textPrimary(context)),
                          decoration: InputDecoration(
                            hintText: AppStrings.searchCountry(lang),
                            hintStyle: TextStyle(
                                color: AppTheme.sheetSecondary(context)),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                          autocorrect: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // List
              Expanded(
                child: vm.isLoadingCountries
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                                color: AppColors.gold),
                            const SizedBox(height: 12),
                            Text(AppStrings.countriesLoading(lang),
                                style: TextStyle(
                                    color: AppTheme.sheetSecondary(context),
                                    fontSize: 14)),
                          ],
                        ),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Text(
                              AppStrings.couldNotLoadCountries(lang),
                              style: TextStyle(color: AppTheme.sheetSecondary(context)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final c = filtered[i];
                              final name = lang == 'tr'
                                  ? c.ulkeAdi
                                  : c.ulkeAdiEn;
                              final selected =
                                  c.id == vm.selectedCountry?.id;

                              return ListTile(
                                title: Text(name,
                                    style: TextStyle(
                                        color: AppTheme.textPrimary(context))),
                                trailing: selected
                                    ? const Icon(AppIcons.check,
                                        color: AppColors.greenAccent,
                                        size: 18)
                                    : null,
                                tileColor: AppTheme.sheetItemBg(context),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await vm.selectCountry(c);
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DiyanetCountry> _filtered(PrayerTimeViewModel vm) {
    if (_search.isEmpty) return vm.countries;
    final q = vm.normalize(_search);
    return vm.countries
        .where((c) =>
            vm.normalize(c.ulkeAdi).contains(q) ||
            vm.normalize(c.ulkeAdiEn).contains(q))
        .toList();
  }
}

// ─── Language Picker Sheet ────────────────────────────────────────────────────

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimeViewModel>(
      builder: (context, vm, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.sheetBg(context),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    const SizedBox(width: 60),
                    const Spacer(),
                    Text(
                      AppStrings.language(vm.language),
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
                        style: TextStyle(
                            color: AppTheme.accentColor(context), fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Language options
              ...AppStrings.languageNames.entries.map((e) {
                final selected = vm.language == e.key;
                return ListTile(
                  title: Text(e.value,
                      style: TextStyle(
                          color: AppTheme.textPrimary(context), fontSize: 16)),
                  trailing: selected
                      ? const Icon(AppIcons.check,
                          color: AppColors.greenAccent, size: 20)
                      : null,
                  tileColor: AppTheme.sheetItemBg(context),
                  onTap: () {
                    Navigator.pop(context);
                    vm.switchLanguage(e.key);
                  },
                );
              }),
              const BannerAdContainer(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        );
      },
    );
  }
}
