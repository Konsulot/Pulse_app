import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../results/domain/models/result_info_data.dart';
import '../../../results/domain/models/table_trans_result.dart';
import '../../../results/domain/services/table_trans_calculator.dart';
import '../controllers/examination_controller.dart';
import '../widgets/exam_exit_button.dart';
import '../../../../core/errors/app_error_message.dart';

class ExaminationResultScreen extends ConsumerStatefulWidget {
  final String examinationId;
  const ExaminationResultScreen({super.key, required this.examinationId});

  @override
  ConsumerState<ExaminationResultScreen> createState() => _ExaminationResultScreenState();
}

class _ExaminationResultScreenState extends ConsumerState<ExaminationResultScreen> {
  bool _synced = false;

  static const double _cellW = 38;
  static const double _cellH = 46;
  static const double _organW = 128;
  static const double _bandW = 40;
  static const double _transitionW = 96;
  static const double _summaryW = 56;
  static const double _summaryH = 40;

  int _sumValue(Map<String, dynamic>? source, String prefix, {int maxIndex = 4}) {
    if (source == null) return 0;
    var total = 0;
    for (int i = 1; i <= maxIndex; i++) {
      total += (source['$prefix$i'] as num?)?.toInt() ?? 0;
    }
    return total;
  }

  ResultInfoData? _buildInfoData(Map<String, dynamic>? star1, Map<String, dynamic>? star2) {
    if (star1 == null || star2 == null) return null;
    return ResultInfoData(
      lung: _sumValue(star1, 'p'),
      hearth: _sumValue(star1, 'c'),
      spleen: _sumValue(star1, 'rp'),
      liver: _sumValue(star1, 'f'),
      pericardium: _sumValue(star2, 'mc', maxIndex: 5),
      kidney: _sumValue(star1, 'r'),
      thelargeintestine: _sumValue(star1, 'gi'),
      thesmallintestine: _sumValue(star1, 'ig'),
      stomach: _sumValue(star1, 'e'),
      gallbladder: _sumValue(star1, 'vb'),
      tr: _sumValue(star2, 'tr', maxIndex: 5),
      bladder: _sumValue(star1, 'v'),
    );
  }

  Map<String, dynamic> _footSelectedCells(Map<String, dynamic>? foot) {
    final selected = foot?['selected_cells'];
    if (selected is Map<String, dynamic>) return selected;
    if (selected is Map) {
      return selected.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  String _hexagramCode(Map<String, dynamic>? foot) {
    final cells = _footSelectedCells(foot);
    final depth = cells['pulse_depth']?.toString() == 'surface' ? '1' : '0';
    final length = cells['pulse_length']?.toString() == 'long' ? '1' : '0';
    final smoothness = cells['pulse_smoothness']?.toString() == 'smooth' ? '1' : '0';
    return '$depth$length$smoothness$depth$length$smoothness';
  }

  Map<String, dynamic>? _keyValues(Map<String, dynamic>? record) {
    final value = record?['key_values'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  Future<void> _syncRecords(TableTransResult result, Map<String, dynamic>? indexrecord, Map<String, dynamic>? foot) async {
    if (_synced) return;
    _synced = true;
    final repo = ref.read(examinationsRepositoryProvider);
    await repo.saveKeyValueRecord(table: 'exam_circlerecord', examinationId: widget.examinationId, keyValues: result.circleIds);
    await repo.saveKeyValueRecord(table: 'exam_crossrecord', examinationId: widget.examinationId, keyValues: result.crossIds);
    await repo.saveKeyValueRecord(table: 'exam_balancerecord', examinationId: widget.examinationId, keyValues: result.balanceValues);
    final existing = Map<String, dynamic>.from(_keyValues(indexrecord) ?? const {});
    await repo.saveKeyValueRecord(
      table: 'exam_indexrecord',
      examinationId: widget.examinationId,
      keyValues: {
        ...existing,
        'circle_ids': result.circleIds,
        'cross_ids': result.crossIds,
        'balance_values': result.balanceValues,
        if (existing.containsKey('meridian_actions')) 'meridian_actions': existing['meridian_actions'],
        'hexagram': existing['hexagram'] ?? {
          'code': _hexagramCode(foot),
          'source': 'derived_from_pulse_parameters',
        },
      },
    );
  }

  Future<void> _complete(BuildContext context, WidgetRef ref, String? patientId) async {
    await ref
        .read(completeExaminationControllerProvider.notifier)
        .complete(widget.examinationId, patientId: patientId);

    if (!context.mounted) return;

    final state = ref.read(completeExaminationControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))),
      );
      return;
    }

    if (patientId != null && patientId.isNotEmpty) {
      context.go('/patients/$patientId');
    } else {
      context.go('/patients');
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String? patientId) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Удалить обследование?',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Обследование и все связанные диагностические данные будут удалены.',
                  style: TextStyle(color: Color(0xFF607D78), height: 1.35),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: const Text('Удалить'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: const Text('Отмена'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true) return;
    await ref.read(deleteExaminationControllerProvider.notifier).delete(
      examinationId: widget.examinationId,
      patientId: patientId,
    );
    final state = ref.read(deleteExaminationControllerProvider);
    if (state.hasError && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))));
      return;
    }
    if (context.mounted && patientId != null) {
      context.go('/patients/$patientId');
    }
  }

  Color _headerColor(String key) {
    switch (key) {
      case 'p':
      case 'gi':
        return Colors.white;
      case 'c':
      case 'ig':
        return const Color(0xFFE79A9A);
      case 'rp':
      case 'e':
        return const Color(0xFFD7E184);
      case 'f':
      case 'vb':
        return const Color(0xFF7BDB72);
      case 'mc':
      case 'tr':
      case 'r':
      case 'v':
        return const Color(0xFFB8B9EA);
      case 'gray':
        return const Color(0xFFBFCBCC);
      default:
        return Colors.white;
    }
  }

  Color _leftBandColor(int step) {
    switch (step) {
      case 0:
        return const Color(0xFFB8B9EA);
      case 1:
        return const Color(0xFF4B50D9);
      case 2:
        return const Color(0xFFC94AC4);
      case 3:
        return const Color(0xFFC74080);
      case 4:
        return const Color(0xFFD59A9A);
      default:
        return Colors.white;
    }
  }

  Color _rightBandColor(int step) {
    switch (step) {
      case 0:
        return const Color(0xFFD59A9A);
      case 1:
        return const Color(0xFFC74080);
      case 2:
        return const Color(0xFFC94AC4);
      case 3:
        return const Color(0xFF4B50D9);
      case 4:
        return const Color(0xFFB8B9EA);
      default:
        return Colors.white;
    }
  }

  String? _resultPointSchemePath(String code) {
    switch (code.toUpperCase()) {
      case 'P':
      case 'C':
      case 'MC':
        return 'assets/images/points/p_c_mc.jpeg';

      case 'GI':
      case 'IG':
      case 'TR':
        return 'assets/images/points/gi_ig_tr.jpeg';

      case 'E':
        return 'assets/images/points/e_vb_leg.jpeg';

      case 'VB':
      case 'F':
        return 'assets/images/points/e_vb_f.png';

      case 'RP':
      case 'R':
        return 'assets/images/points/rp_r.png';

      case 'V':
        return 'assets/images/points/V.jpg';

      default:
        return null;
    }
  }

  void _showResultPointSchemeDialog(String code) {
    final imagePath = _resultPointSchemePath(code);
    if (imagePath == null) return;

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Закрыть',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Схема точки не найдена'),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Точка: ${code.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _resultPointHeaderCell(
    String code, {
    required double w,
    required double h,
    double fontSize = 16,
  }) {
    final upper = code.toUpperCase();
    return InkWell(
      onTap: () => _showResultPointSchemeDialog(upper),
      child: _box(
        w: w,
        h: h,
        color: _headerColor(code.toLowerCase()),
        text: upper,
        weight: FontWeight.w700,
        fontSize: fontSize,
      ),
    );
  }

  Widget _box({
    required double w,
    required double h,
    Color color = Colors.white,
    String? text,
    FontWeight weight = FontWeight.w500,
    double fontSize = 16,
  }) {
    return Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.78),
        border: Border.all(color: Colors.black26),
      ),
      child: text == null
          ? null
          : Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize, fontWeight: weight),
            ),
    );
  }

  Widget _summaryTable(List<String> labels, List<int> values) {
    labels.map((e) => e.toLowerCase()).toList();
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            labels.length,
            (i) => _resultPointHeaderCell(
              labels[i],
              w: _summaryW,
              h: _summaryH,
              fontSize: 18,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(values.length, (i) => _box(
            w: _summaryW,
            h: _summaryH,
            text: values[i].toString(),
            weight: FontWeight.w700,
            fontSize: 18,
          )),
        ),
      ],
    );
  }

  String _energyTitle(Map<String, dynamic>? energy) {
    final result = energy?['result']?.toString() ?? '';

    if (result == 'Победа Инь энергии' || result == 'Победа Ян энергии') {
      return result;
    }

    if (result.contains('distal')) {
      return 'Победа Инь энергии';
    }

    if (result.contains('proximal')) {
      return 'Победа Ян энергии';
    }

    return result.isEmpty ? '—' : result;
  }

  String _openChannelsLabel(Map<String, dynamic>? p9) {
    final result = p9?['result']?.toString() ?? '';
    final direction = p9?['direction']?.toString() ?? '';

    if (result == 'Открыты Инь каналы' || result == 'Открыты Янь каналы') {
      return result;
    }

    if (direction == 'right' || result == 'selected') {
      return 'Открыты Инь каналы';
    }

    if (direction == 'left' || result == 'Открыты Ян каналы') {
      return 'Открыты Янь каналы';
    }

    return result.isEmpty || result == 'none' ? '—' : result;
  }

  Widget _statusCard(String title, String value, Color valueColor) {
    return SizedBox(
      width: 170,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              border: Border.all(color: Colors.black26),
            ),
            child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: valueColor,
              border: Border.all(color: Colors.black26),
            ),
            child: Text(value, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  String _dateText(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    String two(int v) => v.toString().padLeft(2, '0');
    final local = dt.toLocal();
    return '${two(local.day)}.${two(local.month)}.${local.year} ${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }

  Widget _examInfoPanel(Map<String, dynamic>? examination, Map<String, dynamic>? patient, String? doctorName) {
    final fullName = [
      patient?['last_name'],
      patient?['first_name'],
      patient?['middle_name'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(' ');

    Widget valueBox(String value) {
      return Container(
        height: 34,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(border: Border.all(color: Colors.black12), color: Colors.white),
        child: Text(
          value.isEmpty ? '—' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
      );
    }

    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 3),
                    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                  valueBox(value),
                ],
              );
            }

            return Row(
              children: [
                SizedBox(
                  width: 210,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
                Expanded(child: valueBox(value)),
              ],
            );
          },
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row('Дата и время проведения исследования', _dateText(examination?['exam_datetime']?.toString())),
            row('Номер амбулаторной карты', patient?['card_number']?.toString() ?? examination?['legacy_number_card']?.toString() ?? '—'),
            row('ФИО', fullName),
            row('Врач', doctorName?.trim().isNotEmpty == true ? doctorName!.trim() : 'Не указан'),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, bool isBlue) {
    return Container(
      width: 58,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isBlue ? const Color(0xFF6060D9) : const Color(0xFFE35A5A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }

  Widget _humanWayPanel(Map<String, dynamic>? e42) {
    final chiRight = (e42?['chi_cun_right']?.toString() ?? 'Вэй') == 'Чжун';
    final chiLeft = (e42?['chi_cun_left']?.toString() ?? 'Вэй') == 'Чжун';
    final e42Right = (e42?['e42_right']?.toString() ?? 'Вэй') == 'Чжун';
    final e42Left = (e42?['e42_left']?.toString() ?? 'Вэй') == 'Чжун';

    return SizedBox(
      width: 290,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 220,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Image.asset(
                'assets/images/human_model.jpg',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(height: 300),
              ),
            ),
          ),
          Positioned(top: 18, left: 10, child: _badge(chiRight ? 'Чжун' : 'Вэй', chiRight)),
          Positioned(top: 18, right: 10, child: _badge(chiLeft ? 'Чжун' : 'Вэй', chiLeft)),
          Positioned(bottom: 28, left: 10, child: _badge(e42Right ? 'Чжун' : 'Вэй', e42Right)),
          Positioned(bottom: 28, right: 10, child: _badge(e42Left ? 'Чжун' : 'Вэй', e42Left)),
        ],
      ),
    );
  }

  Widget _graphPanel(List<int?> values) {
    Widget overlayBox(int? value, double top, double left) {
      final v = value ?? 0;
      final absValue = v.abs();
      final color = absValue == 0
          ? const Color(0xFF5D86E8)
          : absValue <= 2
              ? const Color(0xFF5F5BE8)
              : absValue == 3
                  ? const Color(0xFFD400C8)
                  : const Color(0xFFF02C92);
      return Positioned(
        top: top,
        left: left,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.78),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(v.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      );
    }

    return SizedBox(
      width: 290,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('График дисбаланса (У-Син)', style: TextStyle(fontSize: 16, color: Colors.black54)),
          ),
          Container(
            width: 250,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
            ),
            child: SizedBox(
              width: 220,
              height: 260,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/double_star.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox(),
                    ),
                  ),
                  // Порядок соответствует таблице дисбаланса:
                  // GI P, IG C, E RP, VB F, TR MC, V R.
                  // Значения ставим между соответствующими парами точек на схеме.
                  overlayBox(values.isNotEmpty ? values[0] : 0, 155, 143), // GI P
                  overlayBox(values.length > 1 ? values[1] : 0, 35, 95), // IG C
                  overlayBox(values.length > 2 ? values[2] : 0, 66, 170), // E RP
                  overlayBox(values.length > 3 ? values[3] : 0, 75, 20), // VB F
                  overlayBox(values.length > 4 ? values[4] : 0, 205, 15), // TR MC
                  overlayBox(values.length > 5 ? values[5] : 0, 165, 55), // V R
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _organBalanceLegend(),
        ],
      ),
    );
  }


  Widget _organBalanceLegend() {
    Widget row(String title, Color color) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 190,
            height: 26,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              color: const Color(0xFFD9D9D9),
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          ),
          Container(
            width: 64,
            height: 26,
            // ignore: deprecated_member_use
            color: color.withOpacity(0.78),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row('Баланс органов', const Color(0xFF5D86E8)),
        row('Слабый дисбаланс', const Color(0xFF5F5BE8)),
        row('Сильный дисбаланс', const Color(0xFFD400C8)),
        row('Выраженный дисбаланс', const Color(0xFFF02C92)),
      ],
    );
  }

  Widget _coloredHeader() {
    return Row(
      children: [
        _box(w: _organW, h: _cellH, color: const Color(0xFFD2DEE0)),
        _box(w: _bandW, h: _cellH, color: const Color(0xFFD2DEE0)),
        ...['p', 'c', 'rp', 'f', 'mc', 'r'].map((k) => _resultPointHeaderCell(k, w: _cellW, h: _cellH)),
        _box(w: _transitionW, h: _cellH, color: _headerColor('gray'), text: 'Переходы 1', weight: FontWeight.w700),
        ...['gi', 'ig', 'e', 'vb', 'tr', 'v'].map((k) => _resultPointHeaderCell(k, w: _cellW, h: _cellH)),
        _box(w: _bandW, h: _cellH, color: const Color(0xFFD2DEE0)),
        _box(w: _organW, h: _cellH, color: const Color(0xFFD2DEE0)),
      ],
    );
  }

  Widget _coloredRow(Map<String, int> m, int step, String leftLabel, String rightLabel) {
    final shownStep = 4 - step;
    return Row(
      children: [
        _box(w: _organW, h: _cellH, text: leftLabel),
        _box(w: _bandW, h: _cellH, color: _leftBandColor(step)),
        ...['p', 'c', 'rp', 'f', 'mc', 'r'].map(
          (k) => _box(
            w: _cellW,
            h: _cellH,
            color: m[k] == shownStep ? _leftBandColor(step) : Colors.white,
          ),
        ),
        _box(
          w: _transitionW,
          h: _cellH,
          color: _headerColor('gray'),
          text: shownStep.toString(),
          weight: FontWeight.w700,
        ),
        ...['gi', 'ig', 'e', 'vb', 'tr', 'v'].map(
          (k) => _box(
            w: _cellW,
            h: _cellH,
            color: m[k] == shownStep ? _rightBandColor(step) : Colors.white,
          ),
        ),
        _box(w: _bandW, h: _cellH, color: _rightBandColor(step)),
        _box(w: _organW, h: _cellH, text: rightLabel),
      ],
    );
  }

  Widget _reportHeader() {
    return Row(
      children: [
        _box(w: _organW, h: _cellH, color: const Color(0xFF8C90EA), text: 'Органы Инь', weight: FontWeight.w700),
        ...['GI\nP', 'IG\nC', 'E\nRP', 'VB\nF', 'TR\nMC', 'V\nR'].asMap().entries.map((entry) {
          const keys = ['gi', 'ig', 'e', 'vb', 'tr', 'v'];
          return _box(w: _cellW, h: _cellH, color: _headerColor(keys[entry.key]), text: entry.value, weight: FontWeight.w700, fontSize: 15);
        }),
        _box(w: _transitionW, h: _cellH, color: _headerColor('gray'), text: 'Переходы', weight: FontWeight.w700),
        ...['P\nGI', 'C\nIG', 'RP\nE', 'F\nVB', 'MC\nTR', 'R\nV'].asMap().entries.map((entry) {
          const keys = ['gi', 'ig', 'e', 'vb', 'tr', 'v'];
          return _box(w: _cellW, h: _cellH, color: _headerColor(keys[entry.key]), text: entry.value, weight: FontWeight.w700, fontSize: 15);
        }),
        _box(w: _organW, h: _cellH, color: const Color(0xFFE69191), text: 'Органы Ян', weight: FontWeight.w700),
      ],
    );
  }


  Widget _pairMarkColumn({
    required bool topCircle,
    required bool bottomCross,
    Color? topColor,
    Color? bottomColor,
  }) {
    return Column(
      children: [
        Container(
          width: _cellW,
          height: _cellH,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: topColor ?? Colors.white, border: Border.all(color: Colors.black26)),
          child: topCircle ? const Text('○', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)) : null,
        ),
        Container(
          width: _cellW,
          height: _cellH,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bottomColor ?? Colors.white, border: Border.all(color: Colors.black26)),
          child: bottomCross ? const Text('×', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)) : null,
        ),
      ],
    );
  }

  Widget _reportPairRow({
    required String leftLabel,
    required String rightLabel,
    required int circleStep,
    required int crossStep,
    required ResultInfoData info,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(w: _organW, h: _cellH * 2, text: leftLabel),
        _pairMarkColumn(
          topCircle: info.thelargeintestine == circleStep,
          bottomCross: info.lung == crossStep,
          topColor: circleStep == 4 ? _headerColor('gray') : null,
          bottomColor: crossStep == 0 ? _headerColor('gray') : null,
        ),
        _pairMarkColumn(
          topCircle: info.thesmallintestine == circleStep,
          bottomCross: info.hearth == crossStep,
          topColor: circleStep == 3 ? _headerColor('gray') : null,
          bottomColor: crossStep == 1 ? _headerColor('gray') : null,
        ),
        _pairMarkColumn(
          topCircle: info.stomach == circleStep,
          bottomCross: info.spleen == crossStep,
          topColor: circleStep == 2 ? _headerColor('gray') : null,
          bottomColor: crossStep == 2 ? _headerColor('gray') : null,
        ),
        _pairMarkColumn(
          topCircle: info.gallbladder == circleStep,
          bottomCross: info.liver == crossStep,
          topColor: circleStep == 1 ? _headerColor('gray') : null,
          bottomColor: crossStep == 3 ? _headerColor('gray') : null,
        ),
        _pairMarkColumn(
          topCircle: info.tr == circleStep,
          bottomCross: info.pericardium == crossStep,
          topColor: circleStep == 0 ? _headerColor('gray') : null,
          bottomColor: crossStep == 4 ? _headerColor('gray') : null,
        ),
        _pairMarkColumn(
          topCircle: info.bladder == circleStep,
          bottomCross: info.kidney == crossStep,
          topColor: circleStep == 0 ? _headerColor('gray') : null,
          bottomColor: crossStep == 4 ? _headerColor('gray') : null,
        ),
        _box(w: _transitionW, h: _cellH * 2, color: _headerColor('gray'), text: (4 - circleStep).toString(), weight: FontWeight.w700),
        _pairMarkColumn(
          topCircle: info.lung == circleStep,
          bottomCross: info.thelargeintestine == crossStep,
          topColor: circleStep == 4 ? _headerColor('gray') : null,
          bottomColor: crossStep == 0 ? _headerColor('gray') : null,
        ),
        _pairMarkColumn(
          topCircle: info.hearth == circleStep,
          bottomCross: info.thesmallintestine == crossStep,
          topColor: circleStep == 3 ? _headerColor('gray') : null,
          bottomColor: crossStep == 1 ? _headerColor('gray') : null,
        ),
        _pairMarkColumn(
          topCircle: info.spleen == circleStep,
          bottomCross: info.stomach == crossStep,
          topColor: circleStep == 2 ? _headerColor('gray') : null,
          bottomColor: crossStep == 2 ? _headerColor('gray') : null,
        ),
        _pairMarkColumn(
          topCircle: info.liver == circleStep,
          bottomCross: info.gallbladder == crossStep,
          topColor: circleStep == 1 ? _headerColor('gray') : null,
          bottomColor: crossStep == 3 ? _headerColor('gray') : null,
        ),
        _pairMarkColumn(
          topCircle: info.pericardium == circleStep,
          bottomCross: info.tr == crossStep,
          topColor: circleStep == 0 ? _headerColor('gray') : null,
          bottomColor: crossStep == 4 ? _headerColor('gray') : null,
        ),
        _pairMarkColumn(
          topCircle: info.kidney == circleStep,
          bottomCross: info.bladder == crossStep,
          topColor: circleStep == 0 ? _headerColor('gray') : null,
          bottomColor: crossStep == 4 ? _headerColor('gray') : null,
        ),
        _box(w: _organW, h: _cellH * 2, text: rightLabel),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(examinationResultProvider(widget.examinationId));
    final completeState = ref.watch(completeExaminationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат обследования'),
        actions: [ExamExitButton(examinationId: widget.examinationId)],
      ),
      body: resultAsync.when(
        data: (result) {
          final patientId = result.examination?['patient_id'] as String?;
          final info = _buildInfoData(result.star1, result.star2);
          final calc = info == null ? null : const TableTransCalculator().calculate(info);
          final channels = info?.toChannelMap();

          if (calc != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _syncRecords(calc, result.indexrecord, result.foot);
            });
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1100;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
                children: [
                  if (info != null && calc != null) ...[
                    _examInfoPanel(result.examination, result.patient, result.doctorName),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 20,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        _summaryTable(const ['P', 'C', 'RP', 'F', 'MC', 'R'], [info.lung, info.hearth, info.spleen, info.liver, info.pericardium, info.kidney]),
                        _summaryTable(const ['GI', 'IG', 'E', 'VB', 'TR', 'V'], [info.thelargeintestine, info.thesmallintestine, info.stomach, info.gallbladder, info.tr, info.bladder]),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 20,
                      runSpacing: 16,
                      children: [
                        _statusCard('Оценка победы Инь-Ян энергии', _energyTitle(result.energy), const Color(0xFFD86A93)),
                        _statusCard('Оценка открытых каналов', _openChannelsLabel(result.p9), const Color(0xFF78A8DA)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text('Таблицы анализа поражений каналов органов инь и ян', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(
                                    children: [
                                      _coloredHeader(),
                                      ...List.generate(5, (i) {
                                        const left = ['Вода', 'Дерево', 'Земля', 'Огонь', 'Металл'];
                                        const right = ['Металл', 'Огонь', 'Земля', 'Дерево', 'Вода'];
                                        return _coloredRow(channels!, i, left[i], right[i]);
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          _humanWayPanel(result.e42),
                        ],
                      )
                    else
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('Таблицы анализа поражений каналов органов инь и ян', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: [
                                _coloredHeader(),
                                ...List.generate(5, (i) {
                                  const left = ['Вода', 'Дерево', 'Земля', 'Огонь', 'Металл'];
                                  const right = ['Металл', 'Огонь', 'Земля', 'Дерево', 'Вода'];
                                  return _coloredRow(channels!, i, left[i], right[i]);
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _humanWayPanel(result.e42),
                        ],
                      ),
                    const SizedBox(height: 28),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                children: [
                                  _reportHeader(),
                                  _reportPairRow(leftLabel: 'Вода', rightLabel: 'Металл', circleStep: 0, crossStep: 4, info: info),
                                  _reportPairRow(leftLabel: 'Дерево', rightLabel: 'Огонь', circleStep: 1, crossStep: 3, info: info),
                                  _reportPairRow(leftLabel: 'Земля', rightLabel: 'Земля', circleStep: 2, crossStep: 2, info: info),
                                  _reportPairRow(leftLabel: 'Огонь', rightLabel: 'Дерево', circleStep: 3, crossStep: 1, info: info),
                                  _reportPairRow(leftLabel: 'Металл', rightLabel: 'Вода', circleStep: 4, crossStep: 0, info: info),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          _graphPanel(calc.balanceValues),
                        ],
                      )
                    else
                      Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: [
                                _reportHeader(),
                                _reportPairRow(leftLabel: 'Вода', rightLabel: 'Металл', circleStep: 0, crossStep: 4, info: info),
                                _reportPairRow(leftLabel: 'Дерево', rightLabel: 'Огонь', circleStep: 1, crossStep: 3, info: info),
                                _reportPairRow(leftLabel: 'Земля', rightLabel: 'Земля', circleStep: 2, crossStep: 2, info: info),
                                _reportPairRow(leftLabel: 'Огонь', rightLabel: 'Дерево', circleStep: 3, crossStep: 1, info: info),
                                _reportPairRow(leftLabel: 'Металл', rightLabel: 'Вода', circleStep: 4, crossStep: 0, info: info),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _graphPanel(calc.balanceValues),
                        ],
                      ),
                    const SizedBox(height: 28),
                  ],
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/examinations/${widget.examinationId}/meridians'),
                    icon: const Icon(Icons.healing),
                    label: const Text('Стимуляция и седация'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/examinations/${widget.examinationId}/hexagram'),
                    icon: const Icon(Icons.auto_graph),
                    label: const Text('Лечение по гексаграмме'),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    title: 'Завершить обследование',
                    isLoading: completeState.isLoading,
                    onPressed: () => _complete(context, ref, patientId),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _delete(context, ref, patientId),
                    icon: const Icon(Icons.delete),
                    label: const Text('Удалить обследование'),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const LoadingView(),
        error: (error, _) => Center(child: Text(appLoadErrorMessage(error), textAlign: TextAlign.center)),
      ),
    );
  }
}
