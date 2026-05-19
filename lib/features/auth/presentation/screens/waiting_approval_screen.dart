import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../../../profiles/presentation/controllers/profiles_controller.dart';
import '../../../../core/errors/app_error_message.dart';

class WaitingApprovalScreen extends ConsumerWidget {
  const WaitingApprovalScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Доступ к системе'),
        actions: [
          IconButton(
            tooltip: 'Обновить',
            onPressed: () => ref.invalidate(currentProfileProvider),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Выйти',
            onPressed: () => _signOut(context, ref),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: profileAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 54, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(
                        appLoadErrorMessage(error, fallback: 'Не удалось загрузить профиль.'),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  data: (profile) {
                    if (profile?.isAdmin == true) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) context.go('/admin');
                      });
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (profile != null && profile.isDoctor && !profile.isActive) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) context.go('/access-disabled');
                      });
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (profile != null && profile.hasClinic) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) context.go('/patients');
                      });
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 64, color: Color(0xFF00857D)),
                        const SizedBox(height: 16),
                        const Text(
                          'Ожидается привязка к клинике',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile != null && profile.fullName?.trim().isNotEmpty == true
                              ? 'Аккаунт ${profile.fullName} создан, но пока не привязан к клинике.'
                              : 'Аккаунт создан, но пока не привязан к клинике.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF607D78), height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'После привязки администратором появится доступ к пациентам и обследованиям.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF607D78), height: 1.4),
                        ),
                        const SizedBox(height: 22),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/profile'),
                          icon: const Icon(Icons.person_outline),
                          label: const Text('Мой профиль'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => ref.invalidate(currentProfileProvider),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Проверить доступ'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
