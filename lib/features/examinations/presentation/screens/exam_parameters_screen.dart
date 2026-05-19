import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/exam_e42_model.dart';
import '../../domain/exam_energy_model.dart';
import '../../domain/exam_foot_model.dart';
import '../../domain/exam_p9_model.dart';
import '../controllers/examination_controller.dart';
import '../widgets/exam_exit_button.dart';
import '../../../../core/errors/app_error_message.dart';

class ExamParametersScreen extends ConsumerStatefulWidget {
  final String examinationId;
  final String? from;

  const ExamParametersScreen({
    super.key,
    required this.examinationId,
    this.from,
  });

  @override
  ConsumerState<ExamParametersScreen> createState() => _ExamParametersScreenState();
}

class _ExamParametersScreenState extends ConsumerState<ExamParametersScreen> {
  bool get _isEditMode => widget.from == 'result';

  String? _yinYang;
  String? _p9Side;
  String? _chiCunSide;
  String? _e42Side;
  String? _pulseDepth;
  String? _pulseLength;
  String? _pulseSmoothness;
  bool _seeded = false;

  bool get _isFormComplete =>
      _yinYang != null &&
      _p9Side != null &&
      _chiCunSide != null &&
      _e42Side != null &&
      _pulseDepth != null &&
      _pulseLength != null &&
      _pulseSmoothness != null;

  String _energyResultFromSelection(String value) {
    if (value.contains('distal')) {
      return 'Победа Инь энергии';
    }

    if (value.contains('proximal')) {
      return 'Победа Ян энергии';
    }

    return value;
  }

  String _p9ResultFromDirection(String direction) {
    if (direction == 'right') {
      return 'Открыты Инь каналы';
    }

    if (direction == 'left') {
      return 'Открыты Ян каналы';
    }

    return direction;
  }

  void _seed(Map<String, dynamic>? energy, Map<String, dynamic>? p9, Map<String, dynamic>? e42, Map<String, dynamic>? foot) {
    if (_seeded) return;
    _seeded = true;

    final energySelected = energy?['selected_cells'];
    if (energySelected is Map && energySelected['yin_yang_energy'] != null) {
      _yinYang = energySelected['yin_yang_energy'].toString();
    } else {
      final energyResult = energy?['result'] as String?;
      if (energyResult != null && energyResult.isNotEmpty) {
        if (energyResult == 'Победа Инь энергии') {
          _yinYang = 'distal_right';
        } else if (energyResult == 'Победа Ян энергии') {
          _yinYang = 'proximal_right';
        } else {
          _yinYang = energyResult;
        }
      }
    }

    final p9Direction = p9?['direction'] as String?;
    final p9Result = p9?['result'] as String?;

    if (p9Direction == 'right' || p9Direction == 'left') {
      _p9Side = p9Direction;
    } else if (p9Result == 'Открыты Инь каналы' || p9Result == 'selected') {
      _p9Side = 'right';
    } else if (p9Result == 'Открыты Янь каналы' || p9Result == 'Открыты Ян каналы') {
      _p9Side = 'left';
    }

    final e42Selected = e42?['selected_cells'];
    if (e42Selected is Map) {
      _chiCunSide = e42Selected['chi_cun'] as String?;
      _e42Side = e42Selected['e42'] as String?;
    } else {
      final chiL = e42?['chi_cun_left'] as String?;
      final chiR = e42?['chi_cun_right'] as String?;
      if (chiR == 'Чжун') _chiCunSide = 'right';
      if (chiL == 'Чжун') _chiCunSide = 'left';

      final e42L = e42?['e42_left'] as String?;
      final e42R = e42?['e42_right'] as String?;
      if (e42L == 'Чжун') _e42Side = 'left';
      if (e42R == 'Чжун') _e42Side = 'right';
    }

    final footSelected = foot?['selected_cells'];
    if (footSelected is Map) {
      _pulseDepth = footSelected['pulse_depth'] as String?;
      _pulseLength = footSelected['pulse_length'] as String?;
      _pulseSmoothness = footSelected['pulse_smoothness'] as String?;
    }
  }

  Future<void> _save() async {
    if (!_isFormComplete) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все параметры перед сохранением.')),
      );
      return;
    }

    final energyModel = ExamEnergyModel(
      examinationId: widget.examinationId,
      result: _energyResultFromSelection(_yinYang!),
      selectedCells: {'yin_yang_energy': _yinYang},
    );

    final p9Model = ExamP9Model(
      examinationId: widget.examinationId,
      result: _p9ResultFromDirection(_p9Side!),
      direction: _p9Side,
    );

    final e42Model = ExamE42Model(
      examinationId: widget.examinationId,
      chiCunLeft: _chiCunSide == 'left' ? 'Чжун' : 'Вэй',
      chiCunRight: _chiCunSide == 'right' ? 'Чжун' : 'Вэй',
      e42Left: _e42Side == 'left' ? 'Чжун' : 'Вэй',
      e42Right: _e42Side == 'right' ? 'Чжун' : 'Вэй',
      selectedCells: {'chi_cun': _chiCunSide, 'e42': _e42Side},
    );

    final footModel = ExamFootModel(
      examinationId: widget.examinationId,
      footStatus: 'pulse_parameters',
      selectedCells: {
        'pulse_depth': _pulseDepth,
        'pulse_length': _pulseLength,
        'pulse_smoothness': _pulseSmoothness,
      },
    );

    await ref.read(saveEnergyControllerProvider.notifier).save(energyModel);
    var state = ref.read(saveEnergyControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))));
      return;
    }

    await ref.read(saveP9ControllerProvider.notifier).save(p9Model);
    state = ref.read(saveP9ControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))));
      return;
    }

    await ref.read(saveE42ControllerProvider.notifier).save(e42Model);
    state = ref.read(saveE42ControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))));
      return;
    }

    await ref.read(saveFootControllerProvider.notifier).save(footModel);
    state = ref.read(saveFootControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))));
      return;
    }

    if (!mounted) return;
    if (_isEditMode) {
      context.go('/examinations/${widget.examinationId}/result');
    } else {
      context.push('/examinations/${widget.examinationId}/result');
    }
  }

  Widget _labelCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _checkCell({required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Center(
          child: selected ? const Icon(Icons.check, size: 24) : null,
        ),
      ),
    );
  }

  Widget _threeColEnergyBlock() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 360),
      child: Column(
        children: [
          const Text(
            'Оценка "Победы Инь и Ян энергии"',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Table(
            border: TableBorder.all(color: Colors.black26),
            columnWidths: const {
              0: FixedColumnWidth(60),
              1: FlexColumnWidth(),
              2: FixedColumnWidth(60),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _checkCell(
                    selected: _yinYang == 'proximal_left',
                    onTap: () => setState(() => _yinYang = 'proximal_left'),
                  ),
                  _labelCell('Проксимально'),
                  _checkCell(
                    selected: _yinYang == 'proximal_right',
                    onTap: () => setState(() => _yinYang = 'proximal_right'),
                  ),
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _checkCell(
                    selected: _yinYang == 'distal_left',
                    onTap: () => setState(() => _yinYang = 'distal_left'),
                  ),
                  _labelCell('Дистально'),
                  _checkCell(
                    selected: _yinYang == 'distal_right',
                    onTap: () => setState(() => _yinYang = 'distal_right'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _p9Block() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 360),
      child: Column(
        children: [
          const Text(
            'Оценка открытых/доминирующих каналов',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Table(
            border: TableBorder.all(color: Colors.black26),
            columnWidths: const {
              0: FixedColumnWidth(80),
              1: FlexColumnWidth(),
              2: FixedColumnWidth(80),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _checkCell(
                    selected: _p9Side == 'left',
                    onTap: () => setState(() => _p9Side = 'left'),
                  ),
                  _labelCell('Точка P9'),
                  _checkCell(
                    selected: _p9Side == 'right',
                    onTap: () => setState(() => _p9Side = 'right'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _e42Block() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 360),
      child: Column(
        children: [
          const Text(
            'Оценка энергии Чхун-Вэй',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Table(
            border: TableBorder.all(color: Colors.black26),
            columnWidths: const {
              0: FixedColumnWidth(80),
              1: FlexColumnWidth(),
              2: FixedColumnWidth(80),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _checkCell(
                    selected: _chiCunSide == 'left',
                    onTap: () => setState(() => _chiCunSide = 'left'),
                  ),
                  _labelCell('Чи-Цунь'),
                  _checkCell(
                    selected: _chiCunSide == 'right',
                    onTap: () => setState(() => _chiCunSide = 'right'),
                  ),
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _checkCell(
                    selected: _e42Side == 'left',
                    onTap: () => setState(() => _e42Side = 'left'),
                  ),
                  _labelCell('E42'),
                  _checkCell(
                    selected: _e42Side == 'right',
                    onTap: () => setState(() => _e42Side = 'right'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _twoChoiceBlock({
    required String title,
    required String leftLabel,
    required String rightLabel,
    required String? value,
    required String leftValue,
    required String rightValue,
    required ValueChanged<String> onChanged,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 360),
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Table(
            border: TableBorder.all(color: Colors.black26),
            columnWidths: const {
              0: FlexColumnWidth(),
              1: FixedColumnWidth(80),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _labelCell(leftLabel),
                  _checkCell(selected: value == leftValue, onTap: () => onChanged(leftValue)),
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _labelCell(rightLabel),
                  _checkCell(selected: value == rightValue, onTap: () => onChanged(rightValue)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBody() {
    return Container(
      padding: const EdgeInsets.all(14),
      color: const Color(0xFFE0F2F1),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _threeColEnergyBlock()),
              const SizedBox(width: 16),
              Expanded(child: _p9Block()),
              const SizedBox(width: 16),
              Expanded(child: _e42Block()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _twoChoiceBlock(
                  title: 'Глубина пульса',
                  leftLabel: 'Поверхностный',
                  rightLabel: 'Глубокий',
                  value: _pulseDepth,
                  leftValue: 'surface',
                  rightValue: 'deep',
                  onChanged: (v) => setState(() => _pulseDepth = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _twoChoiceBlock(
                  title: 'Длина пульса',
                  leftLabel: 'Длинный',
                  rightLabel: 'Короткий',
                  value: _pulseLength,
                  leftValue: 'long',
                  rightValue: 'short',
                  onChanged: (v) => setState(() => _pulseLength = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _twoChoiceBlock(
                  title: 'Гладкость пульса',
                  leftLabel: 'Гладкий',
                  rightLabel: 'Шершавый',
                  value: _pulseSmoothness,
                  leftValue: 'smooth',
                  rightValue: 'rough',
                  onChanged: (v) => setState(() => _pulseSmoothness = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBody() {
    return Container(
      padding: const EdgeInsets.all(14),
      color: const Color(0xFFE0F2F1),
      child: Column(
        children: [
          _threeColEnergyBlock(),
          const SizedBox(height: 16),
          _p9Block(),
          const SizedBox(height: 16),
          _e42Block(),
          const SizedBox(height: 16),
          _twoChoiceBlock(
            title: 'Глубина пульса',
            leftLabel: 'Поверхностный',
            rightLabel: 'Глубокий',
            value: _pulseDepth,
            leftValue: 'surface',
            rightValue: 'deep',
            onChanged: (v) => setState(() => _pulseDepth = v),
          ),
          const SizedBox(height: 16),
          _twoChoiceBlock(
            title: 'Длина пульса',
            leftLabel: 'Длинный',
            rightLabel: 'Короткий',
            value: _pulseLength,
            leftValue: 'long',
            rightValue: 'short',
            onChanged: (v) => setState(() => _pulseLength = v),
          ),
          const SizedBox(height: 16),
          _twoChoiceBlock(
            title: 'Гладкость пульса',
            leftLabel: 'Гладкий',
            rightLabel: 'Шершавый',
            value: _pulseSmoothness,
            leftValue: 'smooth',
            rightValue: 'rough',
            onChanged: (v) => setState(() => _pulseSmoothness = v),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final energyAsync = ref.watch(energyDataProvider(widget.examinationId));
    final p9Async = ref.watch(p9DataProvider(widget.examinationId));
    final e42Async = ref.watch(e42DataProvider(widget.examinationId));
    final footAsync = ref.watch(footDataProvider(widget.examinationId));

    final isSaving =
        ref.watch(saveEnergyControllerProvider).isLoading ||
        ref.watch(saveP9ControllerProvider).isLoading ||
        ref.watch(saveE42ControllerProvider).isLoading ||
        ref.watch(saveFootControllerProvider).isLoading;

    if (energyAsync.hasError) return Scaffold(body: Center(child: Text(appLoadErrorMessage(energyAsync.error), textAlign: TextAlign.center)));
    if (p9Async.hasError) return Scaffold(body: Center(child: Text(appLoadErrorMessage(p9Async.error), textAlign: TextAlign.center)));
    if (e42Async.hasError) return Scaffold(body: Center(child: Text(appLoadErrorMessage(e42Async.error), textAlign: TextAlign.center)));
    if (footAsync.hasError) return Scaffold(body: Center(child: Text(appLoadErrorMessage(footAsync.error), textAlign: TextAlign.center)));

    final initialLoading =
        (energyAsync.isLoading && !energyAsync.hasValue) ||
        (p9Async.isLoading && !p9Async.hasValue) ||
        (e42Async.isLoading && !e42Async.hasValue) ||
        (footAsync.isLoading && !footAsync.hasValue);
    if (initialLoading) {
      return const Scaffold(body: LoadingView());
    }

    _seed(energyAsync.valueOrNull, p9Async.valueOrNull, e42Async.valueOrNull, footAsync.valueOrNull);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Параметры обследования'),
        actions: [ExamExitButton(examinationId: widget.examinationId)],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
            children: [
              isMobile ? _buildMobileBody() : _buildDesktopBody(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Назад'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      title: 'Сохранить результаты',
                      isLoading: isSaving,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
