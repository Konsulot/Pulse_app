import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/loading_view.dart';
import '../../../results/domain/models/result_info_data.dart';
import '../../../results/domain/models/table_trans_result.dart';
import '../../../results/domain/services/table_trans_calculator.dart';
import '../controllers/examination_controller.dart';
import '../../../../core/errors/app_error_message.dart';

class ExaminationMeridiansScreen extends ConsumerStatefulWidget {
  final String examinationId;
  const ExaminationMeridiansScreen({super.key, required this.examinationId});

  @override
  ConsumerState<ExaminationMeridiansScreen> createState() => _ExaminationMeridiansScreenState();
}

class _ExaminationMeridiansScreenState extends ConsumerState<ExaminationMeridiansScreen> {
  bool _meridianSeeded = false;
  final Map<String, String> _stimulateCells = <String, String>{};
  final Map<String, String> _sedateCells = <String, String>{};
  String _stimulateNextColor = 'redpink';
  String _sedateNextColor = 'redpink';

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
    if (selected is Map) return selected.map((key, value) => MapEntry(key.toString(), value));
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
    return value is Map<String, dynamic> ? value : null;
  }

  Map<String, dynamic> _meridianActionsJson() => {
        'stimulate': Map<String, String>.from(_stimulateCells),
        'sedate': Map<String, String>.from(_sedateCells),
      };

  void _loadMeridianSelection(dynamic raw, Map<String, String> target, void Function(String value) setNextColor) {
    target.clear();

    if (raw is Map) {
      for (final entry in raw.entries) {
        final id = entry.key.toString();
        final color = entry.value.toString();
        target[id] = color == 'bluewhite' ? 'bluewhite' : 'redpink';
      }
      setNextColor(target.length.isEven ? 'redpink' : 'bluewhite');
      return;
    }

    if (raw is List) {
      var color = 'redpink';
      for (final item in raw) {
        target[item.toString()] = color;
        color = color == 'redpink' ? 'bluewhite' : 'redpink';
      }
      setNextColor(color);
    }
  }

  void _seedMeridianActions(Map<String, dynamic>? indexrecord) {
    if (_meridianSeeded) return;
    _meridianSeeded = true;
    final actions = _keyValues(indexrecord)?['meridian_actions'];
    if (actions is Map<String, dynamic>) {
      _loadMeridianSelection(actions['stimulate'], _stimulateCells, (value) => _stimulateNextColor = value);
      _loadMeridianSelection(actions['sedate'], _sedateCells, (value) => _sedateNextColor = value);
    }
  }

  Future<void> _saveMeridianActions({
    required TableTransResult calc,
    required Map<String, dynamic>? indexrecord,
    required Map<String, dynamic>? foot,
  }) async {
    final repo = ref.read(examinationsRepositoryProvider);
    final existing = Map<String, dynamic>.from(_keyValues(indexrecord) ?? const {});
    await repo.saveKeyValueRecord(
      table: 'exam_indexrecord',
      examinationId: widget.examinationId,
      keyValues: {
        ...existing,
        'circle_ids': existing['circle_ids'] ?? calc.circleIds,
        'cross_ids': existing['cross_ids'] ?? calc.crossIds,
        'balance_values': existing['balance_values'] ?? calc.balanceValues,
        'meridian_actions': _meridianActionsJson(),
        'hexagram': existing['hexagram'] ?? {
          'code': _hexagramCode(foot),
          'source': 'derived_from_pulse_parameters',
        },
      },
    );
    ref.invalidate(examinationResultProvider(widget.examinationId));
  }

  Color _organTextColor(String code) {
    switch (code) {
      case 'C':
      case 'IG':
        return Colors.red;
      case 'RP':
      case 'E':
        return const Color(0xFFC48A00);
      case 'F':
      case 'VB':
        return Colors.green;
      case 'MC':
      case 'TR':
      case 'R':
      case 'V':
        return Colors.indigo;
      default:
        return Colors.black;
    }
  }

  Widget _stateSummary(ResultInfoData info) {
    final yin = <Map<String, dynamic>>[
      {'code': 'P', 'name': 'Легкие', 'value': info.lung},
      {'code': 'C', 'name': 'Сердце', 'value': info.hearth},
      {'code': 'RP', 'name': 'Селезенка', 'value': info.spleen},
      {'code': 'F', 'name': 'Печень', 'value': info.liver},
      {'code': 'MC', 'name': 'Перикард', 'value': info.pericardium},
      {'code': 'R', 'name': 'Почки', 'value': info.kidney},
    ].where((e) => e['value'] == 0 || e['value'] == 4).toList();

    final yang = <Map<String, dynamic>>[
      {'code': 'GI', 'name': 'Толстый кишечник', 'value': info.thelargeintestine},
      {'code': 'IG', 'name': 'Тонкий кишечник', 'value': info.thesmallintestine},
      {'code': 'E', 'name': 'Желудок', 'value': info.stomach},
      {'code': 'VB', 'name': 'Желчный пузырь', 'value': info.gallbladder},
      {'code': 'TR', 'name': 'Тройной обогреватель', 'value': info.tr},
      {'code': 'V', 'name': 'Мочевой пузырь', 'value': info.bladder},
    ].where((e) => e['value'] == 0 || e['value'] == 4).toList();

    Widget panel(String title, List<Map<String, dynamic>> rows, Color headerColor) {
      return Container(
        constraints: const BoxConstraints(minWidth: 320, maxWidth: 560),
        decoration: BoxDecoration(border: Border.all(color: Colors.black12), color: Colors.white),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              color: headerColor,
              alignment: Alignment.center,
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            if (rows.isEmpty)
              const Padding(padding: EdgeInsets.all(12), child: Text('Крайних состояний нет'))
            else
              ...rows.map((row) {
                final code = row['code'] as String;
                final name = row['name'] as String;
                final value = row['value'] as int;
                final isExcess = value == 4;
                final stateSymbol = isExcess ? 'X' : '0';
                final stateLabel = isExcess ? 'Избыток' : 'Недостаток';
                final stateColor = isExcess ? Colors.black87 : Colors.indigo;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$code ($name)',
                          style: TextStyle(fontWeight: FontWeight.w700, color: _organTextColor(code)),
                        ),
                      ),
                      Text(
                        stateSymbol,
                        style: TextStyle(fontWeight: FontWeight.w700, color: stateColor, fontSize: 18),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 124,
                        child: Text(
                          '$stateLabel ($value)',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      );
    }

    return Column(
      children: [
        const Text('Сводка состояний: Недостаток и Избыток', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(spacing: 16, runSpacing: 16, children: [
          panel('Органы Инь (Zang)', yin, const Color(0xFFD4D5F3)),
          panel('Органы Ян (Fu)', yang, const Color(0xFFE7D0D0)),
        ]),
      ],
    );
  }

  Widget _box({required double w, required double h, Color color = Colors.white, String? text, FontWeight weight = FontWeight.w500, double fontSize = 16}) {
    return Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, border: Border.all(color: Colors.black26)),
      child: text == null ? null : Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: fontSize, fontWeight: weight)),
    );
  }

  Widget _balanceStepsTable(TableTransResult calc) {
    const labels = ['GI P', 'IG C', 'E RP', 'VB F', 'TR MC', 'V R'];
    return Column(
      children: [
        const Text('Расчёт величины дисбаланса в шагах переходов', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(labels.length, (i) => Column(children: [
              _box(w: 92, h: 44, color: const Color(0xFFD2DEE0), text: labels[i], weight: FontWeight.w700),
              _box(w: 92, h: 44, text: (calc.balanceValues.length > i ? calc.balanceValues[i] : 0).toString(), weight: FontWeight.w700),
            ])),
          ),
        ),
      ],
    );
  }

  static const List<Map<String, String>> _meridianRows = [
    {'leftCode': 'P', 'leftStream': 'P10', 'leftSea': 'P5', 'rightCode': 'GI', 'rightStream': 'GI2', 'rightSea': 'GI11'},
    {'leftCode': 'C', 'leftStream': 'C8', 'leftSea': 'C3', 'rightCode': 'IG', 'rightStream': 'IG2', 'rightSea': 'IG8'},
    {'leftCode': 'MC', 'leftStream': 'MC8', 'leftSea': 'MC3', 'rightCode': 'TR', 'rightStream': 'TR2', 'rightSea': 'TR10'},
    {'leftCode': 'RP', 'leftStream': 'RP2', 'leftSea': 'RP9', 'rightCode': 'E', 'rightStream': 'E44', 'rightSea': 'E36'},
    {'leftCode': 'F', 'leftStream': 'F2', 'leftSea': 'F8', 'rightCode': 'VB', 'rightStream': 'VB43', 'rightSea': 'VB34'},
    {'leftCode': 'R', 'leftStream': 'R2', 'leftSea': 'R10', 'rightCode': 'V', 'rightStream': 'V66', 'rightSea': 'V40'},
  ];

  Color _selectionColor(String? colorKey) {
    switch (colorKey) {
      case 'redpink':
        return const Color(0xFFF1B8C4);
      case 'bluewhite':
        return const Color(0xFFDDEBFF);
      default:
        return Colors.white;
    }
  }

  Widget _meridianSelectableCell({required String id, required String text, required Map<String, String> selected, required VoidCallback onTap, double width = 70}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: _selectionColor(selected[id]), border: Border.all(color: Colors.black26)),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _meridianSideHeader() => Row(mainAxisSize: MainAxisSize.min, children: [
    _box(w: 44, h: 40, color: const Color(0xFFC4D0D0)),
    _box(w: 70, h: 40, text: 'Ручей', weight: FontWeight.w700),
    _box(w: 70, h: 40, text: 'Море', weight: FontWeight.w700),
    _box(w: 44, h: 40, color: const Color(0xFFC4D0D0)),
    _box(w: 70, h: 40, text: 'Ручей', weight: FontWeight.w700),
    _box(w: 70, h: 40, text: 'Море', weight: FontWeight.w700),
  ]);

  Widget _meridianSideSubHeader() => Row(mainAxisSize: MainAxisSize.min, children: [
    _box(w: 44, h: 40, color: const Color(0xFFC4D0D0)),
    _box(w: 70, h: 40, text: '2 у-шу', weight: FontWeight.w700, fontSize: 14),
    _box(w: 70, h: 40, text: '5 у-шу', weight: FontWeight.w700, fontSize: 14),
    _box(w: 44, h: 40, color: const Color(0xFFC4D0D0)),
    _box(w: 70, h: 40, text: '2 у-шу', weight: FontWeight.w700, fontSize: 14),
    _box(w: 70, h: 40, text: '5 у-шу', weight: FontWeight.w700, fontSize: 14),
  ]);

  Widget _meridianSideRows({
    required String side,
    required String kind,
    required Map<String, String> selected,
    required TableTransResult calc,
    required Map<String, dynamic>? indexrecord,
    required Map<String, dynamic>? foot,
  }) {
    return Column(
      children: List.generate(_meridianRows.length, (i) {
        final row = _meridianRows[i];

        void toggle(String id) {
          setState(() {
            if (selected.containsKey(id)) {
              selected.remove(id);
            } else if (kind == 'stimulate') {
              selected[id] = _stimulateNextColor;
              _stimulateNextColor = _stimulateNextColor == 'redpink' ? 'bluewhite' : 'redpink';
            } else {
              selected[id] = _sedateNextColor;
              _sedateNextColor = _sedateNextColor == 'redpink' ? 'bluewhite' : 'redpink';
            }
          });
          _saveMeridianActions(calc: calc, indexrecord: indexrecord, foot: foot);
        }

        final prefix = '${kind}_$side';
        return Row(mainAxisSize: MainAxisSize.min, children: [
          _box(w: 44, h: 40, color: const Color(0xFFC4D0D0), text: row['leftCode']!, weight: FontWeight.w700),
          _meridianSelectableCell(id: '${prefix}_${row['leftCode']}_${row['leftStream']}', text: row['leftStream']!, selected: selected, onTap: () => toggle('${prefix}_${row['leftCode']}_${row['leftStream']}')),
          _meridianSelectableCell(id: '${prefix}_${row['leftCode']}_${row['leftSea']}', text: row['leftSea']!, selected: selected, onTap: () => toggle('${prefix}_${row['leftCode']}_${row['leftSea']}')),
          _box(w: 44, h: 40, color: const Color(0xFFC4D0D0), text: row['rightCode']!, weight: FontWeight.w700),
          _meridianSelectableCell(id: '${prefix}_${row['rightCode']}_${row['rightStream']}', text: row['rightStream']!, selected: selected, onTap: () => toggle('${prefix}_${row['rightCode']}_${row['rightStream']}')),
          _meridianSelectableCell(id: '${prefix}_${row['rightCode']}_${row['rightSea']}', text: row['rightSea']!, selected: selected, onTap: () => toggle('${prefix}_${row['rightCode']}_${row['rightSea']}')),
        ]);
      }),
    );
  }

  Widget _bodyBand() => Column(children: [
    _box(w: 64, h: 80, color: const Color(0xFF94CCCC)),
    _box(w: 64, h: 120, color: const Color(0xFF94CCCC), text: 'РУКА', weight: FontWeight.w700),
    _box(w: 64, h: 120, color: const Color(0xFF94CCCC), text: 'НОГА', weight: FontWeight.w700),
  ]);

  Widget _meridianTable({required String title, required String kind, required Map<String, String> selected, required TableTransResult calc, required Map<String, dynamic>? indexrecord, required Map<String, dynamic>? foot}) {
    return Column(children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            _box(w: 368, h: 40, text: 'Справа', weight: FontWeight.w700),
            _box(w: 64, h: 40, color: const Color(0xFF94CCCC)),
            _box(w: 368, h: 40, text: 'Слева', weight: FontWeight.w700),
          ]),
          Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              _meridianSideHeader(),
              _meridianSideSubHeader(),
              _meridianSideRows(side: 'right', kind: kind, selected: selected, calc: calc, indexrecord: indexrecord, foot: foot),
            ]),
            _bodyBand(),
            Column(children: [
              _meridianSideHeader(),
              _meridianSideSubHeader(),
              _meridianSideRows(side: 'left', kind: kind, selected: selected, calc: calc, indexrecord: indexrecord, foot: foot),
            ]),
          ]),
        ]),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(examinationResultProvider(widget.examinationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Стимуляция и седация')),
      body: resultAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => Center(child: Text(appLoadErrorMessage(error), textAlign: TextAlign.center)),
        data: (result) {
          final info = _buildInfoData(result.star1, result.star2);
          if (info == null) return const Center(child: Text('Недостаточно данных для расчёта.'));

          final calc = const TableTransCalculator().calculate(info);
          _seedMeridianActions(result.indexrecord);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
            children: [
              _stateSummary(info),
              const SizedBox(height: 28),
              _balanceStepsTable(calc),
              const SizedBox(height: 28),
              _meridianTable(title: 'Стимулируем меридианы', kind: 'stimulate', selected: _stimulateCells, calc: calc, indexrecord: result.indexrecord, foot: result.foot),
              const SizedBox(height: 28),
              _meridianTable(title: 'Седируем меридианы', kind: 'sedate', selected: _sedateCells, calc: calc, indexrecord: result.indexrecord, foot: result.foot),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
