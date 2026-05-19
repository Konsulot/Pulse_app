import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/exam_p9_model.dart';
import '../controllers/examination_controller.dart';
import '../widgets/exam_exit_button.dart';
import '../../../../core/errors/app_error_message.dart';

class ExamP9Screen extends ConsumerStatefulWidget {
  final String examinationId;
  final String? from;
  const ExamP9Screen({super.key, required this.examinationId, this.from});

  @override
  ConsumerState<ExamP9Screen> createState() => _ExamP9ScreenState();
}

class _ExamP9ScreenState extends ConsumerState<ExamP9Screen> {
  bool get _isEditMode => widget.from == 'result';
  String _selectedResult = 'Открыты Инь каналы';
  String _selectedDirection = 'right';
  bool _seeded = false;

  void _seed(Map<String, dynamic>? data) {
    if (_seeded || data == null) return;
    _seeded = true;
    _selectedResult = (data['result'] as String?) ?? _selectedResult;
    _selectedDirection = (data['direction'] as String?) ?? _selectedDirection;
  }

  Future<void> _save() async {
    final model = ExamP9Model(
      examinationId: widget.examinationId,
      result: _selectedResult,
      direction: _selectedDirection,
    );

    await ref.read(saveP9ControllerProvider.notifier).save(model);
    final state = ref.read(saveP9ControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))));
      return;
    }
    if (mounted) {
      if (_isEditMode) {
        context.go('/examinations/${widget.examinationId}/result');
      } else {
        context.push('/examinations/${widget.examinationId}/e42');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saveP9ControllerProvider);
    final existingAsync = ref.watch(p9DataProvider(widget.examinationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('P9'),
        actions: [ExamExitButton(examinationId: widget.examinationId)],
      ),
      body: existingAsync.when(
        data: (data) {
          _seed(data);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
            children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedDirection,
                  decoration: const InputDecoration(labelText: 'Direction'),
                  items: const [
                    DropdownMenuItem(value: 'right', child: Text('right')),
                    DropdownMenuItem(value: 'left', child: Text('left')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedDirection = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedResult,
                  decoration: const InputDecoration(labelText: 'Результат P9'),
                  items: const [
                    DropdownMenuItem(value: 'Открыты Инь каналы', child: Text('Открыты Инь каналы')),
                    DropdownMenuItem(value: 'Открыты Ян каналы', child: Text('Открыты Ян каналы')),
                    DropdownMenuItem(value: 'Смешанный результат', child: Text('Смешанный результат')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedResult = value);
                  },
                ),
                const SizedBox(height: 16),
                AppButton(title: 'Сохранить P9', isLoading: state.isLoading, onPressed: _save),
              ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(appLoadErrorMessage(e), textAlign: TextAlign.center)),
      ),
    );
  }
}
