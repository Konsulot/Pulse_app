import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_error_message.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordRepeatController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).signUp(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    final authState = ref.read(authControllerProvider);
    if (authState.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(authState.error!, fallback: 'Не удалось зарегистрироваться. Проверьте данные и попробуйте снова.'))),
      );
      return;
    }

    if (!mounted) return;

    final hasSession = Supabase.instance.client.auth.currentSession != null;
    if (hasSession) {
      context.go('/auth-check');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Регистрация создана. Проверьте почту для подтверждения аккаунта.'),
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
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
                        'Новый пользователь',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF005B56),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'После регистрации доступ к пациентам появится только после привязки аккаунта к клинике.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF607D78), height: 1.35),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _fullNameController,
                        label: 'ФИО врача',
                        validator: (value) => Validators.personName(value, label: 'ФИО', required: true),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Пароль',
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
                        title: 'Зарегистрироваться',
                        isLoading: authState.isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: authState.isLoading ? null : () => context.go('/login'),
                        child: const Text('Уже есть аккаунт? Войти'),
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
