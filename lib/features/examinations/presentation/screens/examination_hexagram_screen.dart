import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/loading_view.dart';
import '../controllers/examination_controller.dart';
import '../../../../core/errors/app_error_message.dart';

class ExaminationHexagramScreen extends ConsumerWidget {
  final String examinationId;
  const ExaminationHexagramScreen({super.key, required this.examinationId});

  String _russianDepth(String? value) {
    switch (value) {
      case 'surface':
        return 'Поверхностный';
      case 'deep':
        return 'Глубокий';
      default:
        return '—';
    }
  }

  String _russianLength(String? value) {
    switch (value) {
      case 'long':
        return 'Длинный';
      case 'short':
        return 'Короткий';
      default:
        return '—';
    }
  }

  String _russianSmoothness(String? value) {
    switch (value) {
      case 'smooth':
        return 'Гладкий';
      case 'rough':
        return 'Шершавый';
      default:
        return '—';
    }
  }

  String _digitFromDepth(String? value) => value == 'surface' ? '1' : '0';
  String _digitFromLength(String? value) => value == 'long' ? '1' : '0';
  String _digitFromSmoothness(String? value) => value == 'smooth' ? '1' : '0';

  String _hexagramCode(Map<String, dynamic>? foot, Map<String, dynamic>? indexrecord) {
    final keyValues = indexrecord?['key_values'];
    if (keyValues is Map && keyValues['hexagram'] is Map) {
      final saved = keyValues['hexagram'];
      final code = saved['code']?.toString();
      if (code != null && code.length >= 6) {
        return code.substring(code.length - 6);
      }
    }

    final selectedCells = foot?['selected_cells'];
    final Map<String, dynamic> cells = selectedCells is Map<String, dynamic>
        ? selectedCells
        : selectedCells is Map
            ? selectedCells.map((k, v) => MapEntry(k.toString(), v))
            : const {};

    final depth = cells['pulse_depth']?.toString();
    final length = cells['pulse_length']?.toString();
    final smoothness = cells['pulse_smoothness']?.toString();

    final d = _digitFromDepth(depth);
    final l = _digitFromLength(length);
    final s = _digitFromSmoothness(smoothness);
    return '$d$l$s$d$l$s';
  }

  Widget _lineWidget(String digit) {
    final solid = digit == '1';
    return SizedBox(
      width: 110,
      height: 18,
      child: solid
          ? Container(height: 6, margin: const EdgeInsets.symmetric(vertical: 6), color: Colors.black)
          : Row(
              children: [
                Expanded(child: Container(height: 6, color: Colors.black)),
                const SizedBox(width: 18),
                Expanded(child: Container(height: 6, color: Colors.black)),
              ],
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(value),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(examinationResultProvider(examinationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Лечение по гексаграмме')),
      body: resultAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => Center(child: Text(appLoadErrorMessage(error), textAlign: TextAlign.center)),
        data: (result) {
          final selectedCells = result.foot?['selected_cells'];
          final Map<String, dynamic> cells = selectedCells is Map<String, dynamic>
              ? selectedCells
              : selectedCells is Map
                  ? selectedCells.map((k, v) => MapEntry(k.toString(), v))
                  : const {};
          final depth = cells['pulse_depth']?.toString();
          final length = cells['pulse_length']?.toString();
          final smoothness = cells['pulse_smoothness']?.toString();
          final code = _hexagramCode(result.foot, result.indexrecord);
          final lines = code.split('');
          final topToBottom = lines.reversed.toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
            children: [
              const Center(
                child: Text(
                  'Лечение по гексаграмме',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(6, (index) {
                      final lineNumber = 6 - index;
                      final digit = topToBottom[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 22,
                              child: Text(
                                '$lineNumber:',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            _lineWidget(digit),
                            const SizedBox(width: 10),
                            Text(digit),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Код гексаграммы: $code',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Параметры пульса',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _infoRow('Глубина', _russianDepth(depth)),
              _infoRow('Длина', _russianLength(length)),
              _infoRow('Гладкость', _russianSmoothness(smoothness)),
            ],
          );
        },
      ),
    );
  }
}
