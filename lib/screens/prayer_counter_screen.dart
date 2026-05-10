import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/colors.dart';
import '../services/prayer_counter_service.dart';
import '../widgets/banner_ad_container.dart';

// ── Prayer data ───────────────────────────────────────────────────────────────

class _Prayer {
  final String key;
  final String tr;
  final String en;
  final String ar;
  final IconData icon;

  const _Prayer(this.key, this.tr, this.en, this.ar, this.icon);
}

const _prayers = [
  _Prayer('fajr',    'Sabah',  'Fajr',    'الفجر',  Icons.wb_twilight_rounded),
  _Prayer('dhuhr',   'Öğle',   'Dhuhr',   'الظهر',  Icons.wb_sunny_rounded),
  _Prayer('asr',     'İkindi', 'Asr',     'العصر',  Icons.sunny_snowing),
  _Prayer('maghrib', 'Akşam',  'Maghrib', 'المغرب', Icons.nightlight_round),
  _Prayer('isha',    'Yatsı',  'Isha',    'العشاء', Icons.dark_mode_rounded),
];

// ── Main screen ───────────────────────────────────────────────────────────────

class PrayerCounterScreen extends StatefulWidget {
  final String language;
  const PrayerCounterScreen({super.key, required this.language});

  @override
  State<PrayerCounterScreen> createState() => _PrayerCounterScreenState();
}

class _PrayerCounterScreenState extends State<PrayerCounterScreen> {
  Map<String, double> _rates = {};
  int _totalKaza = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rates = <String, double>{};
    for (final p in _prayers) {
      rates[p.key] = await PrayerCounterService.shared.overallRate(prayerKey: p.key);
    }
    final kaza = await PrayerCounterService.shared.totalKazaPerformed();
    if (mounted) setState(() { _rates = rates; _totalKaza = kaza; _loading = false; });
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _l('Uyarı', 'Warning', 'تحذير'),
          style: TextStyle(color: AppTheme.textPrimary(context), fontWeight: FontWeight.bold),
        ),
        content: Text(
          _l(
            'Tüm namaz sayaçları sıfırlanacak. Bu işlem geri alınamaz. Emin misiniz?',
            'All prayer counters will be reset. This cannot be undone. Are you sure?',
            'سيتم إعادة تعيين جميع عدادات الصلاة. هل أنت متأكد؟',
          ),
          style: TextStyle(color: AppTheme.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              _l('İptal', 'Cancel', 'إلغاء'),
              style: TextStyle(color: AppTheme.textSecondary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(_l('Eminim', "I'm Sure", 'نعم')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PrayerCounterService.shared.resetAll();
      _load();
    }
  }

  void _openStats() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _PrayerStatsScreen(language: widget.language),
    ));
  }

  String _l(String tr, String en, String ar) {
    if (widget.language == 'en') return en;
    if (widget.language == 'ar') return ar;
    return tr;
  }

  String _prayerName(_Prayer p) {
    if (widget.language == 'en') return p.en;
    if (widget.language == 'ar') return p.ar;
    return p.tr;
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.greenAccent;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(context)),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary(context), size: 22),
                    ),
                    Expanded(
                      child: Text(
                        _l('Namaz Sayacı', 'Prayer Tracker', 'عداد الصلاة'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _openStats,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bar_chart_rounded, color: accent, size: 22),
                            const SizedBox(width: 4),
                            Text(
                              _l('İstatistik', 'Statistics', 'إحصائيات'),
                              style: TextStyle(
                                color: accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List
              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      ..._prayers.asMap().entries.map((e) {
                        final p = e.value;
                        final rate = _rates[p.key] ?? 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _PrayerRow(
                            name: _prayerName(p),
                            icon: p.icon,
                            rate: rate,
                          ),
                        );
                      }),
                      // Kaza namazı row (6th item, shows total count)
                      _KazaCountRow(
                        totalKaza: _totalKaza,
                        language: widget.language,
                      ),
                    ],
                  ),
                ),

              // Reset button
              if (!_loading)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _confirmReset,
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: Text(_l('Sayacı Sıfırla', 'Reset Counter', 'إعادة تعيين')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent, width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              const BannerAdContainer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Prayer row card ───────────────────────────────────────────────────────────

class _PrayerRow extends StatelessWidget {
  final String name;
  final IconData icon;
  final double rate;

  const _PrayerRow({
    required this.name,
    required this.icon,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final pctDouble = rate * 100;
    final pct = pctDouble.round();
    final color = _rateColor(pct, isDark: AppTheme.isDark(context));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.divider(context).withValues(alpha: 0.5),
            ),
            child: Icon(icon, size: 20, color: AppTheme.textSecondary(context)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(context),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Text(
              '${pctDouble.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _rateColor(int pct, {bool isDark = true}) {
    if (pct >= 80) return AppColors.greenAccent;
    if (pct >= 50) return isDark ? const Color(0xFFFFD466) : const Color(0xFFAA7700);
    return Colors.redAccent;
  }
}

// ── Kaza count row ────────────────────────────────────────────────────────────

class _KazaCountRow extends StatelessWidget {
  final int totalKaza;
  final String language;

  const _KazaCountRow({required this.totalKaza, required this.language});

  String _l(String tr, String en, String ar) {
    if (language == 'en') return en;
    if (language == 'ar') return ar;
    return tr;
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.greenAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.history_edu_rounded, size: 20, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _l('Kaza Namazı', 'Qada Prayers', 'صلاة القضاء'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(context),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: accent.withValues(alpha: 0.12),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Text(
              _l('$totalKaza vakit', '$totalKaza performed', '$totalKaza صلاة'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats screen (landscape-locked) ──────────────────────────────────────────

class _PrayerStatsScreen extends StatefulWidget {
  final String language;
  const _PrayerStatsScreen({required this.language});

  @override
  State<_PrayerStatsScreen> createState() => _PrayerStatsScreenState();
}

class _PrayerStatsScreenState extends State<_PrayerStatsScreen> {
  // null = all prayers, 'kaza' = kaza mode
  String? _selectedKey;
  List<double> _dailyData = [];
  double _monthRate = 0.0;
  double _yearRate = 0.0;
  int _totalKaza = 0;
  int _missedCount = 0;
  bool _loading = true;

  bool get _isKaza => _selectedKey == 'kaza';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _load();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    if (_isKaza) {
      final daily = await PrayerCounterService.shared.dailyKazaSums(30);
      final kaza = await PrayerCounterService.shared.totalKazaPerformed();
      if (mounted) {
        setState(() {
          _dailyData = daily;
          _totalKaza = kaza;
          _loading = false;
        });
      }
    } else {
      final daily = await PrayerCounterService.shared
          .dailyRates(30, prayerKey: _selectedKey);
      final month = await PrayerCounterService.shared
          .currentMonthRate(prayerKey: _selectedKey);
      final year = await PrayerCounterService.shared
          .currentYearRate(prayerKey: _selectedKey);
      final missed = await PrayerCounterService.shared.missedPrayerCount();
      if (mounted) {
        setState(() {
          _dailyData = daily;
          _monthRate = month;
          _yearRate = year;
          _missedCount = missed;
          _loading = false;
        });
      }
    }
  }

  String _l(String tr, String en, String ar) {
    if (widget.language == 'en') return en;
    if (widget.language == 'ar') return ar;
    return tr;
  }

  String _prayerName(_Prayer p) {
    if (widget.language == 'en') return p.en;
    if (widget.language == 'ar') return p.ar;
    return p.tr;
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.greenAccent;
    final gold = const Color(0xFFFFD466);
    final isDark = AppTheme.isDark(context);
    final divColor = AppTheme.divider(context);
    final bg = AppTheme.cardBg(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(context)),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary(context), size: 22),
                    ),
                    Expanded(
                      child: Text(
                        _l('İstatistikler', 'Statistics', 'إحصائيات'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ),
                    // Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: divColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _selectedKey,
                          dropdownColor: isDark
                              ? const Color(0xFF112035)
                              : const Color(0xFFFFF5EE),
                          style: TextStyle(
                            color: AppTheme.textPrimary(context),
                            fontSize: 14,
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(_l('Tüm Namazlar', 'All Prayers', 'كل الصلوات')),
                            ),
                            ..._prayers.map((p) => DropdownMenuItem<String?>(
                              value: p.key,
                              child: Text(_prayerName(p)),
                            )),
                            DropdownMenuItem<String?>(
                              value: 'kaza',
                              child: Text(_l('Kaza Namazı', 'Qada Prayers', 'صلاة القضاء')),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() => _selectedKey = v);
                            _load();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: Row(
                    children: [
                      // Chart
                      Expanded(
                        flex: 7,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                          child: _buildChart(accent, gold, divColor),
                        ),
                      ),
                      // Side panel
                      SizedBox(
                        width: 140,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
                          child: _buildSidePanel(
                              accent, gold, bg, divColor, isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              const BannerAdContainer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(Color accent, Color gold, Color divColor) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final maxY = _isKaza
        ? (_dailyData.isEmpty ? 10.0 : (_dailyData.reduce((a, b) => a > b ? a : b) * 1.2).clamp(5.0, double.infinity))
        : 100.0;

    final spots = _dailyData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), _isKaza ? e.value : e.value * 100))
        .toList();

    final lineBarData = LineChartBarData(
      spots: spots,
      isCurved: false,
      color: accent,
      barWidth: 2,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          if (!_isKaza && index == 29) {
            return FlDotCirclePainter(
                radius: 5, color: gold, strokeColor: gold, strokeWidth: 0);
          }
          if (spot.y > 0) {
            return FlDotCirclePainter(
                radius: 3, color: accent, strokeColor: accent, strokeWidth: 0);
          }
          return FlDotCirclePainter(
              radius: 0,
              color: Colors.transparent,
              strokeColor: Colors.transparent,
              strokeWidth: 0);
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.20), accent.withValues(alpha: 0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    final hasData = _dailyData.any((v) => v > 0);
    if (!hasData) {
      return Center(
        child: Text(
          _l('Henüz kayıt yok', 'No records yet', 'لا سجلات بعد'),
          style: TextStyle(color: AppTheme.textSecondary(context)),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 29,
        minY: 0,
        maxY: maxY,
        clipData: const FlClipData.all(),
        extraLinesData: _isKaza
            ? null
            : ExtraLinesData(verticalLines: [
                VerticalLine(
                  x: 29,
                  color: gold.withValues(alpha: 0.15),
                  strokeWidth: 18,
                ),
              ]),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _isKaza ? (maxY / 4).ceilToDouble() : 25,
          getDrawingHorizontalLine: (_) => FlLine(
            color: divColor.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _isKaza ? (maxY / 4).ceilToDouble() : 25,
              reservedSize: 32,
              getTitlesWidget: (v, _) => Text(
                _isKaza ? v.toInt().toString() : '${v.toInt()}%',
                style: TextStyle(fontSize: 9, color: AppTheme.textSecondary(context)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx % 5 != 0) return const SizedBox.shrink();
                final date = today.subtract(Duration(days: 29 - idx));
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppTheme.textSecondary(context),
                      fontWeight: (!_isKaza && idx == 29) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.isDark(context)
                ? const Color(0xFF1A3050)
                : const Color(0xFFE8F5E9),
            getTooltipItems: (spots) => spots.map((s) {
              final idx = s.x.toInt();
              final date = today.subtract(Duration(days: 29 - idx));
              final valStr = _isKaza
                  ? s.y.toInt().toString()
                  : '${s.y.toStringAsFixed(1)}%';
              return LineTooltipItem(
                '${date.day}/${date.month}\n$valStr',
                TextStyle(
                  color: (!_isKaza && idx == 29) ? gold : AppColors.greenAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [lineBarData],
        showingTooltipIndicators: [],
      ),
    );
  }

  Widget _buildSidePanel(
      Color accent, Color gold, Color bg, Color divColor, bool isDark) {
    if (_isKaza) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l('Kaza Namazı', 'Qada Prayers', 'صلاة القضاء'),
            style: TextStyle(
                fontSize: 13, color: accent, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _StatCard(
            label: _l('Toplam Kılınan', 'Total Performed', 'إجمالي المُؤدّى'),
            value: '$_totalKaza',
            color: accent,
            bg: bg,
            divColor: divColor,
          ),
        ],
      );
    }

    final monthPct = (_monthRate * 100).round();
    final yearPct = (_yearRate * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        // Legend
        Row(children: [
          Container(width: 12, height: 3, color: gold),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _l('Bugün', 'Today', 'اليوم'),
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ),
        ]),
        const Spacer(),
        _StatCard(
          label: _l('Bu Ay', 'This Month', 'هذا الشهر'),
          value: '${(_monthRate * 100).toStringAsFixed(1)}%',
          color: _rateColor(monthPct, isDark: isDark),
          bg: bg,
          divColor: divColor,
        ),
        const Spacer(flex: 1),
        _StatCard(
          label: _l('Bu Yıl', 'This Year', 'هذا العام'),
          value: '${(_yearRate * 100).toStringAsFixed(1)}%',
          color: _rateColor(yearPct, isDark: isDark),
          bg: bg,
          divColor: divColor,
        ),
        const Spacer(flex: 1),
        _MissedCard(
          missed: _missedCount,
          language: widget.language,
          bg: bg,
          divColor: divColor,
        ),
        const Spacer(),
      ],
    );
  }

  Color _rateColor(int pct, {bool isDark = true}) {
    if (pct >= 80) return AppColors.greenAccent;
    if (pct >= 50)
      return isDark ? const Color(0xFFFFD466) : const Color(0xFFAA7700);
    return Colors.redAccent;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;
  final Color divColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
    required this.divColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary(context))),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}

// ── Missed prayer count card ───────────────────────────────────────────────────

class _MissedCard extends StatelessWidget {
  final int missed;
  final String language;
  final Color bg;
  final Color divColor;

  const _MissedCard({
    required this.missed,
    required this.language,
    required this.bg,
    required this.divColor,
  });

  String _l(String tr, String en, String ar) {
    if (language == 'en') return en;
    if (language == 'ar') return ar;
    return tr;
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) {
        final isDark = AppTheme.isDark(ctx);
        final dialogBg =
            isDark ? const Color(0xFF1A3350) : const Color(0xFFEEF7EE);
        return Dialog(
          backgroundColor: dialogBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.greenAccent, size: 32),
                const SizedBox(height: 12),
                Text(
                  _l(
                    'Uygulama yüklendiğinden beri kılınmayan toplam vakit namazı sayısını gösterir. '
                    'Buradan kılınmayan namaz takibini yapıp eksik namaz kadar kaza namazı kılarak '
                    'sisteme kılınan kaza namazlarını girebilirsiniz.',
                    'Shows the total number of daily prayers not performed since the app was installed. '
                    'You can track missed prayers here and enter the qada prayers you have performed.',
                    'يُظهر العدد الإجمالي للصلوات الفائتة منذ تثبيت التطبيق. '
                    'يمكنك تتبع الصلوات الفائتة وإدخال صلوات القضاء التي أديتها.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary(ctx),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenAccent,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(_l('Tamam', 'OK', 'حسناً')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _l('Kılınmayan Namaz', 'Missed Prayers', 'الصلوات الفائتة'),
                  style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary(context)),
                ),
              ),
              GestureDetector(
                onTap: () => _showInfo(context),
                child: Icon(Icons.info_outline_rounded,
                    size: 14,
                    color: AppTheme.textSecondary(context)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$missed',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
