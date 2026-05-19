import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/russian_date_input_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../controllers/profiles_controller.dart';
import '../../../../core/errors/app_error_message.dart';

class DoctorProfileScreen extends ConsumerStatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  ConsumerState<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends ConsumerState<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _birthDateController = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _specializationController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _seed(dynamic doctor) {
    if (_seeded || doctor == null) return;
    _seeded = true;
    _lastNameController.text = doctor.lastName;
    _firstNameController.text = doctor.firstName;
    _middleNameController.text = doctor.middleName ?? '';
    _specializationController.text = doctor.specialization ?? '';
    _birthDateController.text = AppDateUtils.formatRussianDate(doctor.birthDate);
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    final birthDate = AppDateUtils.tryParseRussianDate(_birthDateController.text);

    await ref.read(updateDoctorProfileControllerProvider.notifier).save(
          lastName: _lastNameController.text.trim(),
          firstName: _firstNameController.text.trim(),
          middleName: _middleNameController.text.trim(),
          specialization: _specializationController.text.trim(),
          birthDate: birthDate,
        );

    final state = ref.read(updateDoctorProfileControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error))));
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Профиль сохранён')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final doctorAsync = ref.watch(currentDoctorProfileProvider);
    final state = ref.watch(updateDoctorProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Мой профиль')),
      body: profileAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => Center(child: Text(appLoadErrorMessage(error, fallback: 'Не удалось загрузить профиль.'), textAlign: TextAlign.center)),
        data: (profile) {
          if (profile?.isDoctor != true) {
            return const Center(child: Text('Редактирование профиля доступно только врачу.'));
          }

          return doctorAsync.when(
            loading: () => const LoadingView(),
            error: (error, _) => Center(child: Text(appLoadErrorMessage(error, fallback: 'Не удалось загрузить данные врача.'), textAlign: TextAlign.center)),
            data: (doctor) {
              _seed(doctor);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Данные врача',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: _lastNameController,
                                label: 'Фамилия *',
                                validator: (value) => Validators.personName(value, label: 'Фамилия', required: true),
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: _firstNameController,
                                label: 'Имя *',
                                validator: (value) => Validators.personName(value, label: 'Имя', required: true),
                              ),
                              const SizedBox(height: 12),
                              AppTextField(controller: _middleNameController, label: 'Отчество', validator: (value) => Validators.personName(value, label: 'Отчество')), 
                              const SizedBox(height: 12),
                              AppTextField(controller: _specializationController, label: 'Специализация', validator: (value) => Validators.optionalText(value, label: 'Специализация')), 
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: _birthDateController,
                                label: 'Дата рождения',
                                keyboardType: TextInputType.number,
                                inputFormatters: [RussianDateInputFormatter()],
                                validator: AppDateUtils.validateRussianBirthDate,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        title: 'Сохранить',
                        isLoading: state.isLoading,
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
