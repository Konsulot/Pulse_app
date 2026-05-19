import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../examinations/data/examinations_repository.dart';
import '../../../examinations/presentation/controllers/examination_controller.dart';
import '../../domain/patient_model.dart';
import '../controllers/patients_controller.dart';
import '../../../../core/errors/app_error_message.dart';

class PatientDetailsScreen extends ConsumerWidget {
  final String patientId;
  const PatientDetailsScreen({super.key, required this.patientId});

  Future<void> _openExamination(BuildContext context, WidgetRef ref, String examinationId) async {
    try {
      final route = await ref.read(examinationResumeRouteProvider(examinationId).future);
      if (context.mounted) context.push(route);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appErrorMessage(error, fallback: 'Не удалось открыть обследование.'))),
      );
    }
  }

  Future<bool> _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(message, style: const TextStyle(color: Color(0xFF607D78), height: 1.35)),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: const Text('Удалить'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: const Text('Отмена'),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  Future<void> _deleteExam(BuildContext context, WidgetRef ref, String examinationId) async {
    final confirmed = await _confirmDelete(
      context,
      title: 'Удалить обследование?',
      message: 'Обследование и все связанные диагностические данные будут удалены.',
    );
    if (!confirmed) return;

    await ref.read(deleteExaminationControllerProvider.notifier).delete(
          examinationId: examinationId,
          patientId: patientId,
        );
    final state = ref.read(deleteExaminationControllerProvider);
    if (state.hasError && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error))));
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Обследование удалено')));
    }
  }

  Future<void> _deletePatient(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirmDelete(
      context,
      title: 'Удалить пациента?',
      message: 'Пациент и все связанные обследования будут удалены из базы данных.',
    );
    if (!confirmed) return;

    await ref.read(deletePatientControllerProvider.notifier).deletePatient(patientId);
    final state = ref.read(deletePatientControllerProvider);
    if (state.hasError && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error))));
      return;
    }
    if (context.mounted) context.go('/patients');
  }

  String _text(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return '—';
    return trimmed;
  }

  String _intText(int? value) => value?.toString() ?? '—';

  String _boolText(bool? value) {
    if (value == null) return '—';
    return value ? 'Да' : 'Нет';
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Color(0xFF607D78))),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  List<Widget> _patientInfo(PatientModel patient) {
    return [
      _section(
        title: 'Основные данные',
        children: [
          _infoRow('ФИО', patient.fullName),
          _infoRow('Номер карты', patient.cardNumber),
          _infoRow('Дата рождения', AppDateUtils.formatDate(patient.birthDate)),
          _infoRow('Пол', patient.genderText),
        ],
      ),
      _section(
        title: 'Документы',
        children: [
          _infoRow('Полис', _text(patient.polis)),
          _infoRow('СНИЛС', _text(patient.snils)),
          _infoRow('Страховая организация', _text(patient.insuranceOrgName)),
        ],
      ),
      _section(
        title: 'Адрес',
        children: [
          _infoRow('Индекс', _intText(patient.postalIndex)),
          _infoRow('Регион', _text(patient.region)),
          _infoRow('Город', _text(patient.city)),
          _infoRow('Улица', _text(patient.street)),
          _infoRow('Дом', _intText(patient.house)),
          _infoRow('Квартира', _intText(patient.room)),
        ],
      ),
      _section(
        title: 'Дополнительно',
        children: [
          _infoRow('Место работы', _text(patient.job)),
          _infoRow('Должность', _text(patient.jobTitle)),
          _infoRow('Образование', _text(patient.education)),
          _infoRow('Инвалидность', _boolText(patient.isDisabled)),
          if (patient.isDisabled == true) _infoRow('Группа инвалидности', _intText(patient.disabilityGroup)),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientDetailsProvider(patientId));
    final examsAsync = ref.watch(patientExaminationsProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка пациента'),
        leading: IconButton(
          tooltip: 'К списку пациентов',
          onPressed: () => context.go('/patients'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/patients/$patientId/edit'),
            icon: const Icon(Icons.edit),
            tooltip: 'Редактировать',
          ),
          IconButton(
            onPressed: () => _deletePatient(context, ref),
            icon: const Icon(Icons.delete),
            tooltip: 'Удалить',
          ),
        ],
      ),
      body: patientAsync.when(
        data: (patient) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ..._patientInfo(patient),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => context.push('/patients/$patientId/examinations/create'),
              icon: const Icon(Icons.add_chart),
              label: const Text('Новое обследование'),
            ),
            const SizedBox(height: 12),
            examsAsync.when(
              data: (exams) {
                final inProgress = exams.where((e) => !ExaminationsRepository.isCompletedStatus(e.status)).toList();
                if (inProgress.isEmpty) return const SizedBox.shrink();
                final lastInProgress = inProgress.first;
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openExamination(context, ref, lastInProgress.id),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Продолжить обследование'),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            const Text('История обследований', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            examsAsync.when(
              data: (exams) {
                if (exams.isEmpty) {
                  return const Card(child: ListTile(title: Text('Обследований пока нет')));
                }
                return Column(
                  children: exams.map((exam) {
                    final doctorName = (exam.doctorName?.trim().isNotEmpty ?? false)
                        ? exam.doctorName!.trim()
                        : 'Не указан';
                    return Card(
                      child: ListTile(
                        title: Text('Обследование от ${AppDateUtils.formatDateTime(exam.examDateTime)}'),
                        subtitle: Text(
                          'Статус: ${ExaminationsRepository.statusLabel(exam.status)}\n'
                          'Врач: $doctorName',
                        ),
                        trailing: IconButton(
                          onPressed: () => _deleteExam(context, ref, exam.id),
                          icon: const Icon(Icons.delete),
                          tooltip: 'Удалить обследование',
                        ),
                        onTap: () => _openExamination(context, ref, exam.id),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LoadingView(),
              ),
              error: (e, _) => Text(appLoadErrorMessage(e, fallback: 'Не удалось загрузить историю обследований.')),
            ),
          ],
        ),
        loading: () => const LoadingView(),
        error: (error, _) => Center(child: Text(appLoadErrorMessage(error), textAlign: TextAlign.center)),
      ),
    );
  }
}
