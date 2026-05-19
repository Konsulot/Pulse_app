import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../auth/presentation/screens/waiting_approval_screen.dart';
import '../../../profiles/presentation/controllers/profiles_controller.dart';
import '../../data/examinations_repository.dart';
import '../controllers/examination_controller.dart';
import '../../../../core/errors/app_error_message.dart';

class CurrentExaminationsScreen extends ConsumerWidget {
  const CurrentExaminationsScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    final gate = profileAsync.when<Widget?>(
      loading: () => const Scaffold(body: LoadingView()),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Текущие обследования')),
        body: Center(child: Text(appLoadErrorMessage(error, fallback: 'Не удалось загрузить профиль.'), textAlign: TextAlign.center)),
      ),
      data: (profile) {
        if (profile?.isAdmin == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/admin');
          });
          return const Scaffold(body: LoadingView());
        }
        if (profile == null || !profile.hasClinic) {
          return const WaitingApprovalScreen();
        }
        return null;
      },
    );

    if (gate != null) return gate;

    final examsAsync = ref.watch(currentExaminationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Текущие обследования'),
        leading: IconButton(
          tooltip: 'К пациентам',
          onPressed: () => context.go('/patients'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            tooltip: 'Мой профиль',
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Обновить',
            onPressed: () => ref.invalidate(currentExaminationsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: examsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => Center(child: Text(appLoadErrorMessage(error), textAlign: TextAlign.center)),
        data: (exams) {
          if (exams.isEmpty) {
            return const EmptyView(message: 'Незавершённых обследований нет');
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentExaminationsProvider);
              await ref.read(currentExaminationsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: exams.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final exam = exams[index];
                final doctorName = (exam.doctorName?.trim().isNotEmpty ?? false)
                    ? exam.doctorName!.trim()
                    : 'Не указан';
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEAF7F4),
                      foregroundColor: Color(0xFF006D67),
                      child: Icon(Icons.play_arrow),
                    ),
                    title: Text(exam.patientName),
                    subtitle: Text(
                      'Карта: ${exam.cardNumber}\n'
                      'Начато: ${AppDateUtils.formatDateTime(exam.examDateTime)}\n'
                      'Статус: ${ExaminationsRepository.statusLabel(exam.status)}\n'
                      'Врач: $doctorName',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openExamination(context, ref, exam.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
