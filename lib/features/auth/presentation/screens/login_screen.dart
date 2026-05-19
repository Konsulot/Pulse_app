import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/auth_error_message.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    final authState = ref.read(authControllerProvider);
    if (authState.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(authState.error!, fallback: 'Не удалось войти. Проверьте email и пароль.'))),
      );
      return;
    }

    if (mounted) context.go('/auth-check');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00857D),
              Color(0xFF006D67),
              Color(0xFF004D49),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Диагностика пульса\nпо «Нань Цзин»',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.18,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 3,
                      width: 92,
                      margin: const EdgeInsets.symmetric(horizontal: 120),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: const Color(0xFFEAF7F4).withOpacity(0.75),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 30,
                            offset: Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Вход в систему',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF005B56),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Вы входите в программу диагностики пульса по «Нань Цзин»',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF607D78),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 30),
                            AppTextField(
                              controller: _emailController,
                              label: 'Email',
                              validator: Validators.email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _passwordController,
                              label: 'Пароль',
                              validator: Validators.password,
                              obscureText: true,
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: authState.isLoading
                                    ? null
                                    : () => context.push('/forgot-password'),
                                child: const Text('Забыли пароль?'),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 54,
                              child: AppButton(
                                title: 'Войти',
                                isLoading: authState.isLoading,
                                onPressed: _submit,
                              ),
                            ),
                            const SizedBox(height: 14),
                            OutlinedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () => context.push('/register'),
                              child: const Text('Зарегистрироваться'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Медицинская информационная система',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD8F2EE),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
