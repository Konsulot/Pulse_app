import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_error_message.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/waiting_approval_screen.dart';
import '../../../profiles/presentation/controllers/profiles_controller.dart';
import '../controllers/patients_controller.dart';

class PatientsListScreen extends ConsumerStatefulWidget {
  const PatientsListScreen({super.key});

  @override
  ConsumerState<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends ConsumerState<PatientsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) context.go('/login');
  }

    @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final profileAsync = ref.watch(currentProfileProvider);

    final accessGate = profileAsync.when<Widget?>(
      loading: () => const Scaffold(body: LoadingView()),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Пациенты')),
        body: ErrorView(
          message: appLoadErrorMessage(error, fallback: 'Не удалось загрузить профиль.'),
          onRetry: () => ref.invalidate(currentProfileProvider),
        ),
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

    if (accessGate != null) return accessGate;

    final patientsAsync = ref.watch(patientsListProvider);
    final title = profileAsync.valueOrNull != null
        ? 'Пациенты — ${profileAsync.valueOrNull!.displayName}'
        : 'Пациенты';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (profileAsync.valueOrNull?.isAdmin == true)
            IconButton(
              onPressed: () => context.push('/admin'),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: 'Администрирование',
            ),
          if (profileAsync.valueOrNull?.hasClinic == true)
            IconButton(
              onPressed: () => context.push('/examinations/current'),
              icon: const Icon(Icons.pending_actions_outlined),
              tooltip: 'Текущие обследования',
            ),
          if (profileAsync.valueOrNull?.isDoctor == true)
            IconButton(
              onPressed: () => context.push('/profile'),
              icon: const Icon(Icons.person_outline),
              tooltip: 'Мой профиль',
            ),
          IconButton(
            onPressed: () => _signOut(context, ref),
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/patients/create'),
        label: const Text('Добавить'),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск по ФИО или номеру карты',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          ref.read(patientSearchQueryProvider.notifier).state = '';
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
              onChanged: (value) {
                ref.read(patientSearchQueryProvider.notifier).state = value;
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: patientsAsync.when(
        data: (patients) {
          if (patients.isEmpty) return const EmptyView(message: 'Пациенты не найдены');
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(patientsListProvider);
              ref.invalidate(currentProfileProvider);
              await ref.read(patientsListProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: patients.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final patient = patients[index];
                return Card(
                  child: ListTile(
                    title: Text(patient.fullName),
                    subtitle: Text(
                      'Карта: ${patient.cardNumber}\nДата рождения: ${AppDateUtils.formatDate(patient.birthDate)}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/patients/${patient.id}'),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
                message: appLoadErrorMessage(error, fallback: 'Не удалось загрузить пациентов.'),
                onRetry: () => ref.invalidate(patientsListProvider),
              ),
      ),
          ),
        ],
      ),
    );
  }
}
