import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_error_message.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordRepeatController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (Supabase.instance.client.auth.currentSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сессия восстановления не найдена. Откройте ссылку из письма ещё раз.'),
        ),
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).updatePassword(
          _passwordController.text.trim(),
        );

    final authState = ref.read(authControllerProvider);
    if (authState.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(authState.error!, fallback: 'Не удалось обновить пароль. Попробуйте открыть ссылку из письма ещё раз.'))),
      );
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль обновлён.')),
      );
      context.go('/auth-check');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Новый пароль')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Создайте новый пароль',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF005B56),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Введите новый пароль для входа в систему.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF607D78), height: 1.35),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Новый пароль',
                        validator: Validators.password,
                        obscureText: true,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _passwordRepeatController,
                        label: 'Повторите пароль',
                        obscureText: true,
                        validator: (value) {
                          final required = Validators.password(value);
                          if (required != null) return required;
                          if (value!.trim() != _passwordController.text.trim()) {
                            return 'Пароли не совпадают';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      AppButton(
                        title: 'Сохранить пароль',
                        isLoading: authState.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
