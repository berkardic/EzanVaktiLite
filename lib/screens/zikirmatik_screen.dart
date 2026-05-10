import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/colors.dart';
import '../services/dhikr_service.dart';
import '../widgets/banner_ad_container.dart';

// ── Dhikr data ───────────────────────────────────────────────────────────────

class _Dhikr {
  final String key;
  final String arabic;
  final String turkish;
  final String english;
  const _Dhikr(this.key, this.arabic, this.turkish, this.english);
}

const _dhikrList = [
  _Dhikr('salavat',      'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ', 'Salavat',                  'Salawat'),
  _Dhikr('lahavle',      'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',              'La Havle',                 'La Hawla'),
  _Dhikr('tevhid',       'لَا إِلَٰهَ إِلَّا اللَّهُ مُحَمَّدٌ رَسُولُ اللَّهِ',  'Kelime-i Tevhid',          'Shahada'),
  _Dhikr('bismillah',    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',                 'Bismillahirrahmanirrahim', 'Bismillah'),
  _Dhikr('subhanallah',  'سُبْحَانَ اللَّهِ',                                        'Sübhanallah',              'Subhanallah'),
  _Dhikr('elhamdulillah','الْحَمْدُ لِلَّهِ',                                        'Elhamdülillah',            'Alhamdulillah'),
  _Dhikr('allahuekber',  'اللَّهُ أَكْبَرُ',                                         'Allahu Ekber',             'Allahu Akbar'),
  _Dhikr('lailahe',      'لَا إِلَٰهَ إِلَّا اللَّهُ',                              'La İlahe İllallah',        'La Ilaha Illallah'),
  _Dhikr('estagfirullah','أَسْتَغْفِرُ اللَّهَ',                                     'Estağfirullah',            'Astaghfirullah'),
];

// ── List screen ──────────────────────────────────────────────────────────────

class ZikirmatikScreen extends StatefulWidget {
  final String language;
  const ZikirmatikScreen({super.key, required this.language});

  @override
  State<ZikirmatikScreen> createState() => _ZikirmatikScreenState();
}

class _ZikirmatikScreenState extends State<ZikirmatikScreen> {
  final _rounds = <String, int>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRounds();
  }

  Future<void> _loadRounds() async {
    final map = <String, int>{};
    for (final d in _dhikrList) {
      map[d.key] = await DhikrService.shared.todayRounds(d.key);
    }
    if (mounted) setState(() { _rounds.addAll(map); _loading = false; });
  }

  void _openDetail(_Dhikr dhikr) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DhikrDetailScreen(dhikr: dhikr, language: widget.language),
      ),
    );
    _loadRounds();
  }

  void _showStats() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _StatsScreen(language: widget.language)),
    );
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.language == 'en' ? 'Warning' : widget.language == 'ar' ? 'تحذير' : 'Uyarı',
          style: TextStyle(
              color: AppTheme.textPrimary(context), fontWeight: FontWeight.bold),
        ),
        content: Text(
          widget.language == 'en'
              ? "Today's dhikr counts will be reset. Are you sure?"
              : widget.language == 'ar'
                  ? 'هل تريد إعادة تعيين عدادات الذكر لليوم؟'
                  : 'Bugünkü tüm zikir sayıları sıfırlanacak. Emin misiniz?',
          style: TextStyle(color: AppTheme.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              widget.language == 'en' ? 'Cancel' : widget.language == 'ar' ? 'إلغاء' : 'İptal',
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
            child: Text(
              widget.language == 'en' ? "I'm Sure" : widget.language == 'ar' ? 'نعم' : 'Eminim',
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DhikrService.shared.resetAllToday();
      _loadRounds();
    }
  }

  String _label(String tr, String en, [String? ar]) {
    if (widget.language == 'en') return en;
    if (widget.language == 'ar') return ar ?? en;
    return tr;
  }

  String _name(_Dhikr d) {
    if (widget.language == 'ar') return d.arabic;
    return widget.language == 'en' ? d.english : d.turkish;
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
                        _label('Zikirmatik', 'Dhikr Counter', 'عداد الذكر'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ),
                    // Stats button: icon + text
                    GestureDetector(
                      onTap: _showStats,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bar_chart_rounded, color: accent, size: 22),
                            const SizedBox(width: 4),
                            Text(
                              _label('İstatistik', 'Statistics', 'إحصائيات'),
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
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    itemCount: _dhikrList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 5),
                    itemBuilder: (context, i) {
                      final d = _dhikrList[i];
                      final rounds = _rounds[d.key] ?? 0;
                      return _DhikrListCard(
                        name: _name(d),
                        rounds: rounds,
                        language: widget.language,
                        onTap: () => _openDetail(d),
                      );
                    },
                  ),
                ),

              // Reset button
              if (!_loading)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _confirmReset,
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: Text(
                        widget.language == 'en'
                            ? 'Reset Counter'
                            : widget.language == 'ar'
                                ? 'إعادة تعيين'
                                : 'Sayacı Sıfırla',
                      ),
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

// ── List card ─────────────────────────────────────────────────────────────────

class _DhikrListCard extends StatelessWidget {
  final String name;
  final int rounds;
  final String language;
  final VoidCallback onTap;

  const _DhikrListCard({
    required this.name,
    required this.rounds,
    required this.language,
    required this.onTap,
  });

  String get _roundsLabel {
    if (language == 'en') return '$rounds rounds';
    if (language == 'ar') return '$rounds دورة';
    return '$rounds tur';
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.greenAccent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider(context)),
        ),
        child: Row(
          children: [
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
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: accent.withValues(alpha: 0.12),
                border: Border.all(color: accent.withValues(alpha: 0.35)),
              ),
              child: Text(
                _roundsLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: AppTheme.textSecondary(context)),
          ],
        ),
      ),
    );
  }
}

// ── Detail screen ─────────────────────────────────────────────────────────────

class _DhikrDetailScreen extends StatefulWidget {
  final _Dhikr dhikr;
  final String language;
  const _DhikrDetailScreen({required this.dhikr, required this.language});

  @override
  State<_DhikrDetailScreen> createState() => _DhikrDetailScreenState();
}

class _DhikrDetailScreenState extends State<_DhikrDetailScreen>
    with SingleTickerProviderStateMixin {
  int _current = 0;  // 0–98
  int _rounds = 0;
  bool _loading = true;

  late final AnimationController _flashCtrl;
  late final Animation<double> _flash;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _flash = CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final current = await DhikrService.shared.currentInRound(widget.dhikr.key);
    final rounds  = await DhikrService.shared.todayRounds(widget.dhikr.key);
    if (mounted) setState(() { _current = current; _rounds = rounds; _loading = false; });
  }

  Future<void> _tap() async {
    await DhikrService.shared.increment(widget.dhikr.key);
    final completedRound = _current == 98;
    setState(() {
      _current = (_current + 1) % 99;
      if (completedRound) _rounds += 1;
    });
    if (completedRound) _flashCtrl.forward(from: 0.0);
  }

  Future<void> _reset() async {
    await DhikrService.shared.resetToday(widget.dhikr.key);
    if (mounted) setState(() { _current = 0; _rounds = 0; });
  }

  String _label(String tr, String en, [String? ar]) {
    if (widget.language == 'en') return en;
    if (widget.language == 'ar') return ar ?? en;
    return tr;
  }

  String get _name {
    if (widget.language == 'ar') return widget.dhikr.arabic;
    return widget.language == 'en' ? widget.dhikr.english : widget.dhikr.turkish;
  }

  String get _todayLabel {
    final r = _rounds;
    if (widget.language == 'en') return 'Today: $r ${r == 1 ? 'round' : 'rounds'}';
    if (widget.language == 'ar') return 'اليوم: $r دورة';
    return 'Bugün: $r tur';
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.greenAccent;
    final isDark = AppTheme.isDark(context);
    final circleSize = MediaQuery.of(context).size.width - 40;

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
                        _name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _reset,
                      tooltip: _label('Sıfırla', 'Reset', 'إعادة'),
                      icon: Icon(Icons.refresh_rounded,
                          color: AppTheme.textSecondary(context), size: 22),
                    ),
                  ],
                ),
              ),

              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                // Tap anywhere in the content area to count
                Expanded(
                  child: GestureDetector(
                    onTap: _tap,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Today's rounds label with flash
                          AnimatedBuilder(
                            animation: _flash,
                            builder: (_, __) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: _flashCtrl.isAnimating
                                      ? accent.withValues(alpha: _flash.value * 0.3)
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  _todayLabel,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: accent,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),

                          // Arc counter — fills screen width
                          SizedBox(
                            width: circleSize,
                            height: circleSize,
                            child: CustomPaint(
                              painter: _ArcPainter(
                                progress: _current / 99.0,
                                trackColor: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.08),
                                progressColor: accent,
                                strokeWidth: 14,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$_current',
                                      style: TextStyle(
                                        fontSize: 68,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary(context),
                                        height: 1.0,
                                      ),
                                    ),
                                    Text(
                                      '/ 99',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.textSecondary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          Text(
                            _label('Saymak için ekrana dokun', 'Tap anywhere to count', 'اضغط في أي مكان للعد'),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                      ],
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

// ── Arc painter ───────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const _ArcPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(center, radius,
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth);

    if (progress <= 0) return;

    canvas.drawArc(
      rect,
      -pi / 2,
      progress * 2 * pi,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.progressColor != progressColor;
}

// ── Statistics screen (landscape-locked) ─────────────────────────────────────

class _StatsScreen extends StatefulWidget {
  final String language;
  const _StatsScreen({required this.language});

  @override
  State<_StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<_StatsScreen> {
  String _selectedKey = _dhikrList.first.key;
  List<int> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _load(_selectedKey);
  }

  Future<void> _load(String key) async {
    setState(() => _loading = true);
    final data = await DhikrService.shared.last30Days(key);
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  int get _total => _data.fold(0, (a, b) => a + b);

  String _label(String tr, String en, [String? ar]) {
    if (widget.language == 'en') return en;
    if (widget.language == 'ar') return ar ?? en;
    return tr;
  }

  String _dhikrName(_Dhikr d) {
    if (widget.language == 'ar') return d.arabic;
    return widget.language == 'en' ? d.english : d.turkish;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final accent = AppColors.greenAccent;
    final bg = isDark ? const Color(0xFF112035) : const Color(0xFFFFF5EE);
    final divColor = AppTheme.divider(context);
    final selectedDhikr = _dhikrList.firstWhere((d) => d.key == _selectedKey);

    // Build chart data first so we can reference it in showingTooltipIndicators
    final spots = _data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();

    final lineBarData = LineChartBarData(
      spots: spots,
      isCurved: false,
      color: accent,
      barWidth: 2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          if (spot.y == 0) {
            return FlDotCirclePainter(
                radius: 0,
                color: Colors.transparent,
                strokeColor: Colors.transparent,
                strokeWidth: 0);
          }
          return FlDotCirclePainter(
              radius: 3, color: accent, strokeColor: accent, strokeWidth: 0);
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.28),
            accent.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    final tooltipIndicators = _data
        .asMap()
        .entries
        .where((e) => e.value > 0)
        .map((e) => ShowingTooltipIndicators([
              LineBarSpot(lineBarData, 0, FlSpot(e.key.toDouble(), e.value.toDouble())),
            ]))
        .toList();

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
                        _label('Son 30 Gün (Tur)', 'Last 30 Days (Rounds)', 'آخر 30 يومًا (دورات)'),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ),
                    // Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: divColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedKey,
                          dropdownColor: bg,
                          style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 14),
                          items: _dhikrList.map((d) => DropdownMenuItem(
                            value: d.key,
                            child: Text(_dhikrName(d)),
                          )).toList(),
                          onChanged: (v) {
                            if (v != null) { setState(() => _selectedKey = v); _load(v); }
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
                          child: _data.every((v) => v == 0)
                              ? Center(
                                  child: Text(
                                    _label('Henüz kayıt yok', 'No records yet', 'لا سجلات بعد'),
                                    style: TextStyle(color: AppTheme.textSecondary(context)),
                                  ),
                                )
                              : LineChart(
                                  LineChartData(
                                    minX: 0,
                                    maxX: 29,
                                    clipData: const FlClipData.all(),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (_) => FlLine(
                                        color: divColor.withValues(alpha: 0.5),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 22,
                                          getTitlesWidget: (v, _) {
                                            final idx = v.toInt();
                                            if (idx % 5 != 0) return const SizedBox.shrink();
                                            final day = 29 - idx;
                                            final date = DateTime.now().subtract(Duration(days: day));
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(
                                                '${date.day}/${date.month}',
                                                style: TextStyle(fontSize: 9, color: AppTheme.textSecondary(context)),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    lineTouchData: LineTouchData(
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipColor: (_) => isDark
                                            ? const Color(0xFF1A3050)
                                            : const Color(0xFFE8F5E9),
                                        getTooltipItems: (spots) =>
                                            spots.map((s) {
                                              final idx = s.x.toInt();
                                              final date = DateTime.now().subtract(Duration(days: 29 - idx));
                                              return LineTooltipItem(
                                                '${date.day}/${date.month}\n${s.y.toInt()}',
                                                TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                    showingTooltipIndicators: tooltipIndicators,
                                    lineBarsData: [lineBarData],
                                  ),
                                ),
                        ),
                      ),
                      // Side panel
                      SizedBox(
                        width: 140,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _dhikrName(selectedDhikr),
                                style: TextStyle(fontSize: 13, color: accent, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardBg(context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: divColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _label('Toplam tur', 'Total rounds', 'إجمالي الدورات'),
                                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_total',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
}
