import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/examination_controller.dart';
import '../../../../core/errors/app_error_message.dart';

class ExamExitButton extends ConsumerWidget {
  final String examinationId;
  final String tooltip;

  const ExamExitButton({
    super.key,
    required this.examinationId,
    this.tooltip = 'К истории пациента',
  });

  Future<void> _goToPatient(BuildContext context, WidgetRef ref) async {
    try {
      final patientId = await ref.read(examinationPatientIdProvider(examinationId).future);
      if (!context.mounted) return;
      if (patientId == null || patientId.isEmpty) {
        context.go('/patients');
        return;
      }
      ref.invalidate(patientExaminationsProvider(patientId));
      context.go('/patients/$patientId');
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appErrorMessage(error, fallback: 'Не удалось выйти к истории пациента.'))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: tooltip,
      onPressed: () => _goToPatient(context, ref),
      icon: const Icon(Icons.assignment_return),
    );
  }
}
