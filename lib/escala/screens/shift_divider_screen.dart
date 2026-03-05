import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../utils/constants.dart';

class ShiftDividerScreen extends StatefulWidget {
  const ShiftDividerScreen({super.key});

  @override
  State<ShiftDividerScreen> createState() => _ShiftDividerScreenState();
}

class _ShiftDividerScreenState extends State<ShiftDividerScreen> {
  late TimeOfDay _startTime;
  TimeOfDay? _endTime;

  /// true = blocos iguais (A), false = intervalo fixo (B)
  bool _equalBlocks = true;

  int _blockCount = 2;
  int? _fixedIntervalMinutes;

  List<TextEditingController> _nameControllers = [];

  List<_Block>? _result;
  int? _totalMinutes;

  static const List<_IntervalOption> _intervalOptions = [
    _IntervalOption(label: '15 min', minutes: 15),
    _IntervalOption(label: '30 min', minutes: 30),
    _IntervalOption(label: '45 min', minutes: 45),
    _IntervalOption(label: '1 h', minutes: 60),
    _IntervalOption(label: '1 h 30', minutes: 90),
    _IntervalOption(label: '2 h', minutes: 120),
  ];

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _startTime = TimeOfDay(hour: now.hour, minute: now.minute);
    _endTime = _defaultEndForStart(_startTime);
    _syncNameControllers();
  }

  TimeOfDay _defaultEndForStart(TimeOfDay start) {
    final m = start.hour * 60 + start.minute;
    if (m >= 7 * 60 && m < 19 * 60) {
      return const TimeOfDay(hour: 19, minute: 0);
    }
    return const TimeOfDay(hour: 7, minute: 0);
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncNameControllers() {
    while (_nameControllers.length < _blockCount) {
      final i = _nameControllers.length + 1;
      _nameControllers.add(TextEditingController(text: 'Plantonista $i'));
    }
    while (_nameControllers.length > _blockCount) {
      _nameControllers.removeLast().dispose();
    }
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  void _calculate() {
    if (_endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.shiftDividerMissingEnd)),
      );
      return;
    }

    if (_equalBlocks && _blockCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.shiftDividerMissingBlocks)),
      );
      return;
    }

    if (!_equalBlocks && _fixedIntervalMinutes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.shiftDividerMissingInterval)),
      );
      return;
    }

    int startMin = _toMinutes(_startTime);
    int endMin = _toMinutes(_endTime!);
    if (endMin <= startMin) endMin += 24 * 60;
    final total = endMin - startMin;

    final blocks = <_Block>[];

    if (_equalBlocks) {
      final blockDuration = total / _blockCount;
      double cursor = startMin.toDouble();
      for (int i = 0; i < _blockCount; i++) {
        final bStart = cursor.round();
        final bEnd = (cursor + blockDuration).round();
        blocks.add(_Block(
          start: TimeOfDay(
              hour: (bStart % 1440) ~/ 60, minute: (bStart % 1440) % 60),
          end: TimeOfDay(hour: (bEnd % 1440) ~/ 60, minute: (bEnd % 1440) % 60),
        ));
        cursor += blockDuration;
      }
    } else {
      final interval = _fixedIntervalMinutes!;
      int cursor = startMin;
      while (cursor + interval <= endMin) {
        final bStart = cursor;
        final bEnd = cursor + interval;
        blocks.add(_Block(
          start: TimeOfDay(
              hour: (bStart % 1440) ~/ 60, minute: (bStart % 1440) % 60),
          end: TimeOfDay(hour: (bEnd % 1440) ~/ 60, minute: (bEnd % 1440) % 60),
        ));
        cursor += interval;
      }
      if (cursor < endMin) {
        blocks.add(_Block(
          start: TimeOfDay(
              hour: (cursor % 1440) ~/ 60, minute: (cursor % 1440) % 60),
          end: _endTime!,
        ));
      }
    }

    setState(() {
      _totalMinutes = total;
      _result = blocks;
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : (_endTime ?? _startTime);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
        _endTime = _defaultEndForStart(picked);
      } else {
        _endTime = picked;
      }
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Text(
          AppStrings.shiftDividerTitle,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _buildTimeSelectors(colorScheme),
          const SizedBox(height: AppSpacing.lg),
          _buildMethodSelector(colorScheme),
          const SizedBox(height: AppSpacing.lg),
          _buildMethodOptions(colorScheme),
          const SizedBox(height: AppSpacing.xl),
          _buildCalculateButton(colorScheme),
          if (_result != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildResultCard(colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelectors(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          children: [
            _buildTimeTile(
              label: AppStrings.shiftDividerCurrentTime,
              value: _formatTime(_startTime),
              icon: Icons.access_time,
              colorScheme: colorScheme,
              onTap: () => _pickTime(isStart: true),
            ),
            const Divider(height: 1),
            _buildTimeTile(
              label: AppStrings.shiftDividerEndTime,
              value: _endTime != null ? _formatTime(_endTime!) : '--:--',
              icon: Icons.timer_off_outlined,
              colorScheme: colorScheme,
              onTap: () => _pickTime(isStart: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile({
    required String label,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: AppRadius.card,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.button,
              ),
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelector(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.shiftDividerMethod,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text(AppStrings.shiftDividerEqualBlocks,
                        softWrap: false),
                    icon: Icon(Icons.view_column_outlined, size: 18),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(AppStrings.shiftDividerFixedInterval,
                        softWrap: false),
                    icon: Icon(Icons.timer_outlined, size: 18),
                  ),
                ],
                selected: {_equalBlocks},
                onSelectionChanged: (v) {
                  setState(() {
                    _equalBlocks = v.first;
                    _result = null;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOptions(ColorScheme colorScheme) {
    if (_equalBlocks) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.grid_view, color: colorScheme.primary, size: 22),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      AppStrings.shiftDividerBlockCount,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _blockCount > 2
                        ? () => setState(() {
                              _blockCount--;
                              _syncNameControllers();
                              _result = null;
                            })
                        : null,
                  ),
                  Text(
                    '$_blockCount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() {
                      _blockCount++;
                      _syncNameControllers();
                      _result = null;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...List.generate(_blockCount, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: TextField(
                    controller: _nameControllers[i],
                    decoration: InputDecoration(
                      labelText: 'Plantonista ${i + 1}',
                      prefixIcon: Icon(Icons.person_outline,
                          color: colorScheme.primary, size: 20),
                      isDense: true,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    color: colorScheme.primary, size: 22),
                const SizedBox(width: AppSpacing.md),
                Text(
                  AppStrings.shiftDividerInterval,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _intervalOptions.map((opt) {
                final selected = _fixedIntervalMinutes == opt.minutes;
                return ChoiceChip(
                  label: Text(opt.label),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _fixedIntervalMinutes = opt.minutes;
                      _result = null;
                    });
                  },
                  selectedColor: colorScheme.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color:
                        selected ? colorScheme.primary : colorScheme.onSurface,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _calculate,
        icon: const Icon(Icons.calculate),
        label: const Text(
          AppStrings.shiftDividerCalculate,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _buildClipboardText() {
    final buf = StringBuffer();
    buf.writeln('⏱ Divisor de Plantão');
    buf.writeln('Tempo restante: ${_formatDuration(_totalMinutes!)}');
    buf.writeln();
    final blocks = _result!;
    for (int i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      final name = (_equalBlocks && i < _nameControllers.length)
          ? _nameControllers[i].text.trim()
          : '';
      if (name.isNotEmpty) {
        buf.writeln('$name');
      }
      buf.writeln('${_formatTime(b.start)} → ${_formatTime(b.end)}');
      if (i < blocks.length - 1) buf.writeln();
    }
    return buf.toString();
  }

  void _copyToClipboard() {
    final text = _buildClipboardText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copiado para a área de transferência')),
    );
  }

  Widget _buildResultCard(ColorScheme colorScheme) {
    final blocks = _result!;
    final methodLabel = _equalBlocks
        ? '${AppStrings.shiftDividerEqualBlocks} ($_blockCount)'
        : '${AppStrings.shiftDividerFixedInterval} (${_formatDuration(_fixedIntervalMinutes!)})';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: colorScheme.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${AppStrings.shiftDividerTotalRemaining}: ${_formatDuration(_totalMinutes!)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: colorScheme.primary, size: 20),
                  tooltip: 'Copiar',
                  onPressed: _copyToClipboard,
                ),
              ],
            ),
            Text(
              methodLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: AppSpacing.xl),
            ...List.generate(blocks.length, (i) {
              final b = blocks[i];
              final name = (_equalBlocks && i < _nameControllers.length)
                  ? _nameControllers[i].text.trim()
                  : '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${i + 1}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 4,
                      height: name.isNotEmpty ? 40 : 28,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (name.isNotEmpty)
                            Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                            ),
                          Text(
                            '${_formatTime(b.start)}  →  ${_formatTime(b.end)}',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Block {
  final TimeOfDay start;
  final TimeOfDay end;
  const _Block({required this.start, required this.end});
}

class _IntervalOption {
  final String label;
  final int minutes;
  const _IntervalOption({required this.label, required this.minutes});
}
