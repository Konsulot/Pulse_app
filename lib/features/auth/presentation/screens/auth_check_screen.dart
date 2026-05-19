import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_error_message.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../profiles/presentation/controllers/profiles_controller.dart';

class AuthCheckScreen extends ConsumerWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Проверка доступа')),
        body: ErrorView(
          message: appLoadErrorMessage(error, fallback: 'Не удалось загрузить профиль.'),
          onRetry: () => ref.invalidate(currentProfileProvider),
        ),
      ),
      data: (profile) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          final currentProfile = profile;
          if (currentProfile?.isAdmin == true) {
            context.go('/admin');
          } else if (currentProfile != null && currentProfile.isDoctor && !currentProfile.isActive) {
            context.go('/access-disabled');
          } else if (currentProfile == null || !currentProfile.hasClinic) {
            context.go('/waiting-approval');
          } else {
            context.go('/patients');
          }
        });

        return const Scaffold(body: LoadingView());
      },
    );
  }
}
