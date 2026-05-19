import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/exam_star1_model.dart';
import '../controllers/examination_controller.dart';
import '../widgets/exam_exit_button.dart';
import '../../../../core/errors/app_error_message.dart';

class ExamStar1Part2Screen extends ConsumerStatefulWidget {
  final String examinationId;
  final String? from;

  const ExamStar1Part2Screen({
    super.key,
    required this.examinationId,
    this.from,
  });

  @override
  ConsumerState<ExamStar1Part2Screen> createState() => _ExamStar1Part2ScreenState();
}

class _ExamStar1Part2ScreenState extends ConsumerState<ExamStar1Part2Screen> {
  bool get _isEditMode => widget.from == 'result';

  final Map<String, int> _values = {for (final key in _allKeys) key: 0};
  String _currentHandAsset = 'assets/images/hands.jpg';
  bool _seeded = false;
  bool _didPrecache = false;

  static const List<_StarPairRow> _rows = [
    _StarPairRow(leftLabel: 'RP', leftKey: 'rp3', rightKey: 'f2', rightLabel: 'F'),
    _StarPairRow(leftLabel: 'E', leftKey: 'e3', rightKey: 'vb2', rightLabel: 'VB'),
    _StarPairRow(leftLabel: 'RP', leftKey: 'rp4', rightKey: 'r2', rightLabel: 'R'),
    _StarPairRow(leftLabel: 'E', leftKey: 'e4', rightKey: 'v2', rightLabel: 'V'),
    _StarPairRow(leftLabel: 'R', leftKey: 'r3', rightKey: 'f3', rightLabel: 'F'),
    _StarPairRow(leftLabel: 'V', leftKey: 'v3', rightKey: 'vb3', rightLabel: 'VB'),
    _StarPairRow(leftLabel: 'F', leftKey: 'f4', rightKey: 'c3', rightLabel: 'C'),
    _StarPairRow(leftLabel: 'VB', leftKey: 'vb4', rightKey: 'ig3', rightLabel: 'IG'),
  ];

  static final List<String> _allKeys = [
    'p1','p2','p3','p4',
    'rp1','rp2','rp3','rp4',
    'r1','r2','r3','r4',
    'gi1','gi2','gi3','gi4',
    'e1','e2','e3','e4',
    'vb1','vb2','vb3','vb4',
    'v1','v2','v3','v4',
    'c1','c2','c3','c4',
    'f1','f2','f3','f4',
    'ig1','ig2','ig3','ig4',
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

  ExamStar1Model _buildModel() {
    return ExamStar1Model(
      examinationId: widget.examinationId,
      p1: _values['p1']!, p2: _values['p2']!, p3: _values['p3']!, p4: _values['p4']!,
      rp1: _values['rp1']!, rp2: _values['rp2']!, rp3: _values['rp3']!, rp4: _values['rp4']!,
      r1: _values['r1']!, r2: _values['r2']!, r3: _values['r3']!, r4: 0,
      gi1: _values['gi1']!, gi2: _values['gi2']!, gi3: _values['gi3']!, gi4: _values['gi4']!,
      e1: _values['e1']!, e2: _values['e2']!, e3: _values['e3']!, e4: _values['e4']!,
      vb1: _values['vb1']!, vb2: _values['vb2']!, vb3: _values['vb3']!, vb4: _values['vb4']!,
      v1: _values['v1']!, v2: _values['v2']!, v3: _values['v3']!, v4: 0,
      c1: _values['c1']!, c2: _values['c2']!, c3: _values['c3']!, c4: 0,
      f1: _values['f1']!, f2: _values['f2']!, f3: _values['f3']!, f4: _values['f4']!,
      ig1: _values['ig1']!, ig2: _values['ig2']!, ig3: _values['ig3']!, ig4: 0,
    );
  }

  Future<void> _saveFinal() async {
    if (!_validateRows()) return;
    await ref.read(saveStar1ControllerProvider.notifier).save(_buildModel());
    final state = ref.read(saveStar1ControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))));
      return;
    }
    if (mounted) {
      if (_isEditMode) {
        context.go('/examinations/${widget.examinationId}/result');
      } else {
        context.push('/examinations/${widget.examinationId}/star2');
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
          border: Border.all(color: selected ? const Color(0xFF00796B) : Colors.black26, width: selected ? 2 : 1),
        ),
        child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : const SizedBox.shrink(),
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
          style: const TextStyle(fontWeight: FontWeight.w600, decoration: TextDecoration.underline, color: Colors.black87),
        ),
      ),
    );
  }

  TableRow _headerRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFE0F2F1)),
      children: [SizedBox(height: 22), SizedBox(height: 22), SizedBox(height: 22), SizedBox(height: 22)],
    );
  }

  TableRow _buildRow(_StarPairRow row, int index) {
    final rowColor = index.isEven ? Colors.white : const Color(0xFFF7FBFA);
    return TableRow(
      decoration: BoxDecoration(color: rowColor),
      children: [
        Padding(padding: const EdgeInsets.all(8), child: _buildChannelLabel(row.leftLabel)),
        Padding(padding: const EdgeInsets.all(4), child: _buildChoiceCell(row.leftKey, row.rightKey)),
        Padding(padding: const EdgeInsets.all(4), child: _buildChoiceCell(row.rightKey, row.leftKey)),
        Padding(padding: const EdgeInsets.all(8), child: _buildChannelLabel(row.rightLabel)),
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
      children: [_headerRow(), for (int i = 0; i < _rows.length; i++) _buildRow(_rows[i], i)],
    );
  }

  Widget _buildReferenceImages() {
    return Column(
      children: [
        Container(
          width: 260,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8), color: Colors.white),
          child: Image.asset(_currentHandAsset, width: 240, fit: BoxFit.contain, gaplessPlayback: true),
        ),
        const SizedBox(height: 20),
        Container(
          width: 260,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8), color: Colors.white),
          child: Image.asset('assets/images/star1.jpg', width: 240, fit: BoxFit.contain),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(saveStar1ControllerProvider);
    final existingAsync = ref.watch(star1DataProvider(widget.examinationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сравнение пульсов по основной звезде — часть 2'),
        actions: [ExamExitButton(examinationId: widget.examinationId)],
      ),
      body: existingAsync.when(
        data: (data) {
          _seed(data);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
            children: [
              const Text(
                'Продолжение таблицы сравнения',
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Назад к первой части'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      title: 'Сохранить результаты',
                      isLoading: saveState.isLoading,
                      onPressed: _saveFinal,
                    ),
                  ),
                ],
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
