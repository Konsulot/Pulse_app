import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/exam_foot_model.dart';
import '../controllers/examination_controller.dart';
import '../widgets/exam_exit_button.dart';
import '../../../../core/errors/app_error_message.dart';

class ExamFootScreen extends ConsumerStatefulWidget {
  final String examinationId;
  final String? from;
  const ExamFootScreen({super.key, required this.examinationId, this.from});

  @override
  ConsumerState<ExamFootScreen> createState() => _ExamFootScreenState();
}

class _ExamFootScreenState extends ConsumerState<ExamFootScreen> {
  bool get _isEditMode => widget.from == 'result';
  String _selected = 'Норма';
  bool _seeded = false;

  void _seed(Map<String, dynamic>? data) {
    if (_seeded || data == null) return;
    _seeded = true;
    _selected = (data['foot_status'] as String?) ?? _selected;
  }

  Future<void> _save() async {
    final model = ExamFootModel(examinationId: widget.examinationId, footStatus: _selected);
    await ref.read(saveFootControllerProvider.notifier).save(model);
    final state = ref.read(saveFootControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))));
      return;
    }
    if (mounted) {
      if (_isEditMode) {
        context.go('/examinations/${widget.examinationId}/result');
      } else {
        context.push('/examinations/${widget.examinationId}/result');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saveFootControllerProvider);
    final existingAsync = ref.watch(footDataProvider(widget.examinationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foot'),
        actions: [ExamExitButton(examinationId: widget.examinationId)],
      ),
      body: existingAsync.when(
        data: (data) {
          _seed(data);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
            children: [
                DropdownButtonFormField<String>(
                  initialValue: _selected,
                  decoration: const InputDecoration(labelText: 'Статус стопы'),
                  items: const [
                    DropdownMenuItem(value: 'Норма', child: Text('Норма')),
                    DropdownMenuItem(value: 'Левая активна', child: Text('Левая активна')),
                    DropdownMenuItem(value: 'Правая активна', child: Text('Правая активна')),
                    DropdownMenuItem(value: 'Дисбаланс', child: Text('Дисбаланс')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selected = value);
                  },
                ),
                const SizedBox(height: 16),
                AppButton(title: 'Сохранить Foot', isLoading: state.isLoading, onPressed: _save),
              ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(appLoadErrorMessage(e), textAlign: TextAlign.center)),
      ),
    );
  }
}
