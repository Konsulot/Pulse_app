import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/examination_controller.dart';
import '../../../../core/errors/app_error_message.dart';

class ExaminationCreateScreen extends ConsumerWidget {
  final String patientId;
  const ExaminationCreateScreen({super.key, required this.patientId});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final exam = await ref.read(createExaminationControllerProvider.notifier).createExamination(patientId: patientId);
    final state = ref.read(createExaminationControllerProvider);
    if (state.hasError && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))));
      return;
    }
    if (exam != null && context.mounted) context.push('/examinations/${exam.id}/star1');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createExaminationControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Новое обследование')),
      body: Center(
        child: AppButton(
          title: 'Создать обследование',
          isLoading: state.isLoading,
          onPressed: () => _create(context, ref),
        ),
      ),
    );
  }
}
