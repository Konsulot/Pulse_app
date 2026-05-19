import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/exam_star2_model.dart';
import '../controllers/examination_controller.dart';
import '../widgets/exam_exit_button.dart';
import '../../../../core/errors/app_error_message.dart';

class ExamStar2Screen extends ConsumerStatefulWidget {
  final String examinationId;
  final String? from;

  const ExamStar2Screen({
    super.key,
    required this.examinationId,
    this.from,
  });

  @override
  ConsumerState<ExamStar2Screen> createState() => _ExamStar2ScreenState();
}

class _ExamStar2ScreenState extends ConsumerState<ExamStar2Screen> {
  bool get _isEditMode => widget.from == 'result';

  final Map<String, int> _values = {
    for (final key in _allKeys) key: 0,
  };

  String _currentHandAsset = 'assets/images/hands.jpg';
  bool _seeded = false;
  bool _didPrecache = false;

  static const List<_StarPairRow> _rows = [
    _StarPairRow(leftLabel: 'MC', leftKey: 'mc1', rightKey: 'c5', rightLabel: 'C'),
    _StarPairRow(leftLabel: 'TR', leftKey: 'tr1', rightKey: 'ig5', rightLabel: 'IG'),
    _StarPairRow(leftLabel: 'MC', leftKey: 'mc2', rightKey: 'f5', rightLabel: 'F'),
    _StarPairRow(leftLabel: 'TR', leftKey: 'tr2', rightKey: 'vb5', rightLabel: 'VB'),
    _StarPairRow(leftLabel: 'MC', leftKey: 'mc3', rightKey: 'r5', rightLabel: 'R'),
    _StarPairRow(leftLabel: 'TR', leftKey: 'tr3', rightKey: 'v5', rightLabel: 'V'),
    _StarPairRow(leftLabel: 'MC', leftKey: 'mc4', rightKey: 'rp5', rightLabel: 'RP'),
    _StarPairRow(leftLabel: 'TR', leftKey: 'tr4', rightKey: 'e5', rightLabel: 'E'),
    _StarPairRow(leftLabel: 'MC', leftKey: 'mc5', rightKey: 'p5', rightLabel: 'P'),
    _StarPairRow(leftLabel: 'TR', leftKey: 'tr5', rightKey: 'gi5', rightLabel: 'GI'),
  ];

  static final List<String> _allKeys = [
    'mc1','mc2','mc3','mc4','mc5',
    'tr1','tr2','tr3','tr4','tr5',
    'r5','gi5','e5','vb5','v5','c5','f5','ig5','p5','rp5',
  ];

  static const Map<String, String> _handAssetByChannel = {
    'C': 'assets/images/points/C_hands.png',
    'E': 'assets/images/points/E_hands.jpg',
    'F': 'assets/images/points/F_hands.jpg',
    'GI': 'assets/images/points/GI_hands.jpg',
    'IG': 'assets/images/points/IG_hands.png',
    'MC': 'assets/images/points/MC_hands.jpg',
    'P': 'assets/images/points/P_hands.jpg',
    'R': 'assets/images/points/R_hands.jpg',
    'RP': 'assets/images/points/RP_hands.jpg',
    'TR': 'assets/images/points/TR_hands.jpg',
    'VB': 'assets/images/points/VB_hands.jpg',
    'V': 'assets/images/points/Y_hands.jpg',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) return;
    _didPrecache = true;

    final assets = <String>{
      'assets/images/hands.jpg',
      'assets/images/star1.jpg',
      'assets/images/star2.jpg',
      ..._handAssetByChannel.values,
    };

    for (final asset in assets) {
      precacheImage(AssetImage(asset), context);
    }
  }

  void _seed(Map<String, dynamic>? data) {
    if (_seeded || data == null) return;
    _seeded = true;
    for (final key in _allKeys) {
      _values[key] = (data[key] as num?)?.toInt() ?? 0;
    }
  }

  void _showChannel(String channel) {
    setState(() {
      _currentHandAsset = _handAssetByChannel[channel] ?? 'assets/images/hands.jpg';
    });
  }

  void _select(String activeKey, String inactiveKey) {
    setState(() {
      _values[activeKey] = 1;
      _values[inactiveKey] = 0;
    });
  }

  bool get _allRowsSelected {
    return _rows.every((row) => _values[row.leftKey] == 1 || _values[row.rightKey] == 1);
  }

  bool _validateRows() {
    if (_allRowsSelected) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Выберите значение в каждой строке таблицы')),
    );
    return false;
  }

  ExamStar2Model _buildModel() {
    return ExamStar2Model(
      examinationId: widget.examinationId,
      mc1: _values['mc1']!,
      mc2: _values['mc2']!,
      mc3: _values['mc3']!,
      mc4: _values['mc4']!,
      mc5: _values['mc5']!,
      tr1: _values['tr1']!,
      tr2: _values['tr2']!,
      tr3: _values['tr3']!,
      tr4: _values['tr4']!,
      tr5: _values['tr5']!,
      r5: _values['r5']!,
      gi5: _values['gi5']!,
      e5: _values['e5']!,
      vb5: _values['vb5']!,
      v5: _values['v5']!,
      c5: _values['c5']!,
      f5: _values['f5']!,
      ig5: _values['ig5']!,
      p5: _values['p5']!,
      rp5: _values['rp5']!,
    );
  }

  Future<void> _save() async {
    if (!_validateRows()) return;
    await ref.read(saveStar2ControllerProvider.notifier).save(_buildModel());
    final state = ref.read(saveStar2ControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))),
      );
      return;
    }
    if (mounted) {
      if (_isEditMode) {
        context.go('/examinations/${widget.examinationId}/result');
      } else {
        context.push('/examinations/${widget.examinationId}/parameters');
      }
    }
  }

  Widget _buildChoiceCell(String key, String otherKey) {
    final selected = _values[key] == 1;
    return InkWell(
      onTap: () => _select(key, otherKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00796B) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF00796B) : Colors.black26,
            width: selected ? 2 : 1,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildChannelLabel(String label) {
    return InkWell(
      onTap: () => _showChannel(label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  TableRow _headerRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFE0F2F1)),
      children: [
        SizedBox(height: 22),
        SizedBox(height: 22),
        SizedBox(height: 22),
        SizedBox(height: 22),
      ],
    );
  }

  TableRow _buildRow(_StarPairRow row, int index) {
    final rowColor = index.isEven ? Colors.white : const Color(0xFFF7FBFA);
    return TableRow(
      decoration: BoxDecoration(color: rowColor),
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: _buildChannelLabel(row.leftLabel),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: _buildChoiceCell(row.leftKey, row.rightKey),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: _buildChoiceCell(row.rightKey, row.leftKey),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: _buildChannelLabel(row.rightLabel),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Table(
      border: TableBorder.all(color: Colors.black26),
      columnWidths: const {
        0: FixedColumnWidth(70),
        1: FixedColumnWidth(56),
        2: FixedColumnWidth(56),
        3: FixedColumnWidth(70),
      },
      children: [
        _headerRow(),
        for (int i = 0; i < _rows.length; i++) _buildRow(_rows[i], i),
      ],
    );
  }

  Widget _buildReferenceImages() {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 250,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Image.asset(_currentHandAsset, width: 230, fit: BoxFit.contain, gaplessPlayback: true),
          ),
          const SizedBox(height: 16),
          Container(
            width: 250,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Image.asset('assets/images/star2.jpg', width: 230, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(saveStar2ControllerProvider);
    final existingAsync = ref.watch(star2DataProvider(widget.examinationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сравнение пульсов по дополнительной звезде'),
        actions: [ExamExitButton(examinationId: widget.examinationId)],
      ),
      body: existingAsync.when(
        data: (data) {
          _seed(data);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
            children: [
              const Text(
                'Сравнение пульсов по дополнительной звезде',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTable(),
                    const SizedBox(width: 16),
                    _buildReferenceImages(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                title: 'Сохранить результаты',
                isLoading: saveState.isLoading,
                onPressed: _save,
              ),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(appLoadErrorMessage(e), textAlign: TextAlign.center)),
      ),
    );
  }
}

class _StarPairRow {
  final String leftLabel;
  final String leftKey;
  final String rightKey;
  final String rightLabel;

  const _StarPairRow({
    required this.leftLabel,
    required this.leftKey,
    required this.rightKey,
    required this.rightLabel,
  });
}
