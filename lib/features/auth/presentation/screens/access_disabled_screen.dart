import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../../../profiles/presentation/controllers/profiles_controller.dart';
import '../../../../core/errors/app_error_message.dart';

class AccessDisabledScreen extends ConsumerWidget {
  const AccessDisabledScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Доступ отключён'),
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
                  error: (error, _) => Text(
                    appLoadErrorMessage(error, fallback: 'Не удалось загрузить профиль.'),
                    textAlign: TextAlign.center,
                  ),
                  data: (profile) {
                    final currentProfile = profile;
                    if (currentProfile?.isAdmin == true) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) context.go('/admin');
                      });
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (currentProfile != null && currentProfile.isDoctor && currentProfile.isActive && currentProfile.hasClinic) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) context.go('/patients');
                      });
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (currentProfile != null && currentProfile.isDoctor && currentProfile.isActive && !currentProfile.hasClinic) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) context.go('/waiting-approval');
                      });
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Доступ отключён администратором',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentProfile != null && currentProfile.fullName?.trim().isNotEmpty == true
                              ? 'Аккаунт ${currentProfile.fullName} сейчас не имеет доступа к пациентам и обследованиям.'
                              : 'Аккаунт сейчас не имеет доступа к пациентам и обследованиям.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF607D78), height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Для восстановления доступа обратитесь к администратору.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF607D78), height: 1.4),
                        ),
                        const SizedBox(height: 22),
                        OutlinedButton(
                          onPressed: () => ref.invalidate(currentProfileProvider),
                          child: const Text('Проверить доступ'),
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
