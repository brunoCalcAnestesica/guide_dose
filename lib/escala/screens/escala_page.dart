import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blocked_day_provider.dart';
import '../providers/report_provider.dart';
import '../providers/shift_provider.dart';
import '../services/repass_reminder_notification_service.dart';
import '../utils/constants.dart';
import '../widgets/calendar_tab.dart';
import '../widgets/history_tab.dart';
import 'escala_settings_screen.dart';
import 'reports_screen.dart';

class _SyncProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shiftLoading = context.select<ShiftProvider, bool>((p) => p.isLoading);
    final reportLoading = context.select<ReportProvider, bool>((p) => p.isLoading);
    final isLoading = shiftLoading || reportLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: isLoading ? 3.0 : 0.0,
      child: isLoading
          ? LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class EscalaPage extends StatefulWidget {
  final int? initialTabIndex;

  const EscalaPage({super.key, this.initialTabIndex});

  @override
  State<EscalaPage> createState() => _EscalaPageState();
}

class _DeferredTabBody extends StatefulWidget {
  const _DeferredTabBody({
    required this.tabIndex,
    required this.initialTabIndex,
    required this.child,
  });

  final int tabIndex;
  final int initialTabIndex;
  final Widget child;

  @override
  State<_DeferredTabBody> createState() => _DeferredTabBodyState();
}

class _DeferredTabBodyState extends State<_DeferredTabBody> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    if (widget.tabIndex == widget.initialTabIndex) {
      _showContent = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showContent = true);
      });
    }
  }

  @override
  void didUpdateWidget(_DeferredTabBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_showContent && widget.tabIndex == widget.initialTabIndex) {
      _showContent = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showContent) {
      return RepaintBoundary(
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const SizedBox.expand(),
        ),
      );
    }
    return RepaintBoundary(child: widget.child);
  }
}

class _EscalaPageState extends State<EscalaPage> {
  late int _initialTabIndex;
  late int _selectedIndex;
  ShiftProvider? _shiftProvider;
  BlockedDayProvider? _blockedDayProvider;
  VoidCallback? _repassListener;
  Timer? _repassScheduleTimer;
  static const Duration _repassDebounce = Duration(milliseconds: 700);

  Future<void> _updateRepassSchedule() async {
    if (!mounted) return;
    final sp = context.read<ShiftProvider>();
    final bp = context.read<BlockedDayProvider>();
    await RepassReminderNotificationService.requestPermission(context);
    if (!mounted) return;
    await RepassReminderNotificationService.updateSchedule(sp, bp);
  }

  void _scheduleRepassUpdate() {
    _repassScheduleTimer?.cancel();
    _repassScheduleTimer = Timer(_repassDebounce, () async {
      _repassScheduleTimer = null;
      await _updateRepassSchedule();
    });
  }

  void _attachRepassListeners() {
    if (_repassListener != null) return;
    _shiftProvider = context.read<ShiftProvider>();
    _blockedDayProvider = context.read<BlockedDayProvider>();
    _repassListener = () => _scheduleRepassUpdate();
    _shiftProvider!.addListener(_repassListener!);
    _blockedDayProvider!.addListener(_repassListener!);
  }

  @override
  void initState() {
    super.initState();
    _initialTabIndex = widget.initialTabIndex ?? 0;
    _selectedIndex = _initialTabIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlockedDayProvider>().load();
      RepassReminderNotificationService.initialize(null).then((_) async {
        if (!mounted) return;
        await _updateRepassSchedule();
        if (!mounted) return;
        _attachRepassListeners();
      });
    });
  }

  @override
  void dispose() {
    _repassScheduleTimer?.cancel();
    if (_repassListener != null) {
      _shiftProvider?.removeListener(_repassListener!);
      _blockedDayProvider?.removeListener(_repassListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Text(
          AppStrings.appTitle,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: colorScheme.onPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const EscalaSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _SyncProgressBar(),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _DeferredTabBody(
                  tabIndex: 0,
                  initialTabIndex: _initialTabIndex,
                  child: const CalendarTab(),
                ),
                _DeferredTabBody(
                  tabIndex: 1,
                  initialTabIndex: _initialTabIndex,
                  child: const HistoryTab(),
                ),
                _DeferredTabBody(
                  tabIndex: 2,
                  initialTabIndex: _initialTabIndex,
                  child: const ReportsScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: scheme.primary,
            unselectedItemColor: scheme.onSurface.withValues(alpha: 0.6),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today),
                label: AppStrings.calendarTab,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.description_outlined),
                label: AppStrings.historyTab,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.inventory_2_outlined),
                label: 'Relatórios',
              ),
            ],
          );
        },
      ),
    );
  }
}
