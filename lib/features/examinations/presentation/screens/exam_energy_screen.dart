import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/exam_energy_model.dart';
import '../controllers/examination_controller.dart';
import '../widgets/exam_exit_button.dart';
import '../../../../core/errors/app_error_message.dart';

class ExamEnergyScreen extends ConsumerStatefulWidget {
  final String examinationId;
  final String? from;
  const ExamEnergyScreen({super.key, required this.examinationId, this.from});

  @override
  ConsumerState<ExamEnergyScreen> createState() => _ExamEnergyScreenState();
}

class _ExamEnergyScreenState extends ConsumerState<ExamEnergyScreen> {
  bool get _isEditMode => widget.from == 'result';
  String _selected = 'Победа Инь энергии';
  bool _seeded = false;

  void _seed(Map<String, dynamic>? data) {
    if (_seeded || data == null) return;
    _seeded = true;
    _selected = (data['result'] as String?) ?? 'Победа Инь энергии';
  }

  Future<void> _save() async {
    final model = ExamEnergyModel(examinationId: widget.examinationId, result: _selected);
    await ref.read(saveEnergyControllerProvider.notifier).save(model);
    final state = ref.read(saveEnergyControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))));
      return;
    }
    if (mounted) {
      if (_isEditMode) {
        context.go('/examinations/${widget.examinationId}/result');
      } else {
        context.push('/examinations/${widget.examinationId}/p9');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saveEnergyControllerProvider);
    final existingAsync = ref.watch(energyDataProvider(widget.examinationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy'),
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
                  decoration: const InputDecoration(labelText: 'Результат Energy'),
                  items: const [
                    DropdownMenuItem(value: 'Победа Инь энергии', child: Text('Победа Инь энергии')),
                    DropdownMenuItem(value: 'Победа Ян энергии', child: Text('Победа Ян энергии')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selected = value);
                  },
                ),
                const SizedBox(height: 16),
                AppButton(title: 'Сохранить Energy', isLoading: state.isLoading, onPressed: _save),
              ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(appLoadErrorMessage(e), textAlign: TextAlign.center)),
      ),
    );
  }
}
