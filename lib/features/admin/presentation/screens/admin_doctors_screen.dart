import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profiles/presentation/controllers/profiles_controller.dart';
import '../../domain/admin_models.dart';
import '../controllers/admin_controller.dart';
import '../../../../core/errors/app_error_message.dart';

class AdminDoctorsScreen extends ConsumerWidget {
  const AdminDoctorsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) context.go('/login');
  }

  void _showSnack(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(adminClinicsProvider);
    ref.invalidate(adminDoctorsProvider);
    await Future.wait([
      ref.read(adminClinicsProvider.future),
      ref.read(adminDoctorsProvider.future),
    ]);
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String actionText,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
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
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF607D78),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    child: Text(actionText),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                    child: const Text('Отмена'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  Future<void> _showClinicSheet(
    BuildContext context,
    WidgetRef ref, {
    ClinicAdminModel? clinic,
  }) async {
    final formKey = GlobalKey<FormState>();
    final shortNameController = TextEditingController(text: clinic?.shortName ?? '');
    final fullNameController = TextEditingController(text: clinic?.fullName ?? '');
    final ogrnController = TextEditingController(text: clinic?.ogrn ?? '');
    final addressController = TextEditingController(text: clinic?.address ?? '');
    final postalIndexController = TextEditingController(text: clinic?.postalIndex?.toString() ?? '');
    final phoneController = TextEditingController(text: clinic?.phone ?? '');
    final emailController = TextEditingController(text: clinic?.email ?? '');
    final chiefController = TextEditingController(text: clinic?.chiefDoctorName ?? '');
    final deputyController = TextEditingController(text: clinic?.deputyChiefDoctorName ?? '');
    final isEditing = clinic != null;
    final postalIndexFormatters = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)];
    final ogrnFormatters = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(15)];
    var isSaving = false;

    int? intValue(TextEditingController controller) {
      final text = controller.text.trim();
      if (text.isEmpty) return null;
      return int.tryParse(text);
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> save() async {
              if (formKey.currentState?.validate() != true) return;
              FocusManager.instance.primaryFocus?.unfocus();
              setSheetState(() => isSaving = true);

              try {
                final repository = ref.read(adminRepositoryProvider);
                if (isEditing) {
                  await repository.updateClinic(
                    clinicId: clinic.id,
                    shortName: shortNameController.text,
                    fullName: fullNameController.text,
                    ogrn: ogrnController.text,
                    address: addressController.text,
                    postalIndex: intValue(postalIndexController),
                    phone: phoneController.text,
                    email: emailController.text,
                    chiefDoctorName: chiefController.text,
                    deputyChiefDoctorName: deputyController.text,
                  );
                } else {
                  await repository.createClinic(
                    shortName: shortNameController.text,
                    fullName: fullNameController.text,
                    ogrn: ogrnController.text,
                    address: addressController.text,
                    postalIndex: intValue(postalIndexController),
                    phone: phoneController.text,
                    email: emailController.text,
                    chiefDoctorName: chiefController.text,
                    deputyChiefDoctorName: deputyController.text,
                  );
                }

                if (!sheetContext.mounted) return;
                Navigator.of(sheetContext).pop();
                ref.invalidate(adminClinicsProvider);
                ref.invalidate(adminDoctorsProvider);
                _showSnack(context, isEditing ? 'Клиника сохранена' : 'Клиника создана');
              } catch (error) {
                if (!sheetContext.mounted) return;
                setSheetState(() => isSaving = false);
                _showSnack(context, appErrorMessage(error, fallback: 'Не удалось сохранить клинику.'));
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isEditing ? 'Редактировать клинику' : 'Создать клинику',
                        style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: shortNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Краткое название *'),
                        validator: (value) {
                          final required = Validators.requiredField(value, label: 'Краткое название');
                          if (required != null) return required;
                          return Validators.optionalText(value, label: 'Краткое название', maxLength: 120);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: fullNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Полное название'),
                        validator: (value) => Validators.optionalText(value, label: 'Полное название', maxLength: 200),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ogrnController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'ОГРН'),
                        inputFormatters: ogrnFormatters,
                        keyboardType: TextInputType.number,
                        validator: Validators.ogrn,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Адрес'),
                        validator: (value) => Validators.optionalText(value, label: 'Адрес', maxLength: 250),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: postalIndexController,
                        keyboardType: TextInputType.number,
                        inputFormatters: postalIndexFormatters,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Почтовый индекс'),
                        validator: Validators.postalIndex,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Телефон'),
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: Validators.optionalEmail,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: chiefController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Главный врач'),
                        validator: (value) => Validators.optionalText(value, label: 'Главный врач', maxLength: 120),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: deputyController,
                        decoration: const InputDecoration(labelText: 'Заместитель главного врача'),
                        validator: (value) => Validators.optionalText(value, label: 'Заместитель главного врача', maxLength: 120),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isSaving ? null : save,
                          child: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Сохранить'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: isSaving
                              ? null
                              : () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  Navigator.of(sheetContext).pop();
                                },
                          child: const Text('Отмена'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

  }

  Future<void> _deleteClinic(
    BuildContext context,
    WidgetRef ref,
    ClinicAdminModel clinic,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Удалить клинику?',
      message: 'Клиника «${clinic.shortName}» будет удалена. Врачи, пациенты и обследования потеряют привязку к этой клинике.',
      actionText: 'Удалить',
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(adminRepositoryProvider).deleteClinic(clinic.id);
      ref.invalidate(adminClinicsProvider);
      ref.invalidate(adminDoctorsProvider);
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Клиника удалена');
    } catch (error) {
      // ignore: use_build_context_synchronously
      _showSnack(context, appErrorMessage(error, fallback: 'Не удалось удалить клинику.'));
    }
  }

  Future<void> _assign(
    BuildContext context,
    WidgetRef ref,
    DoctorAdminModel doctor,
    ClinicAdminModel clinic,
  ) async {
    try {
      await ref.read(adminRepositoryProvider).assignDoctorToClinic(
            profileId: doctor.id,
            clinicId: clinic.id,
          );
      ref.invalidate(adminDoctorsProvider);
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Врач привязан к клинике «${clinic.shortName}»');
    } catch (error) {
      // ignore: use_build_context_synchronously
      _showSnack(context, appErrorMessage(error, fallback: 'Не удалось привязать врача.'));
    }
  }

  Future<void> _detach(BuildContext context, WidgetRef ref, DoctorAdminModel doctor) async {
    try {
      await ref.read(adminRepositoryProvider).detachDoctorFromClinic(doctor.id);
      ref.invalidate(adminDoctorsProvider);
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Врач отвязан от клиники');
    } catch (error) {
      // ignore: use_build_context_synchronously
      _showSnack(context, appErrorMessage(error, fallback: 'Не удалось отвязать врача.'));
    }
  }

  Future<void> _disableDoctorAccess(
    BuildContext context,
    WidgetRef ref,
    DoctorAdminModel doctor,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Отключить доступ врача?',
      message: 'Врач «${doctor.displayName}» потеряет доступ к пациентам и обследованиям. Аккаунт в Supabase Auth останется.',
      actionText: 'Отключить доступ',
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(adminRepositoryProvider).disableDoctorAccess(doctor.id);
      ref.invalidate(adminDoctorsProvider);
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Доступ врача отключён');
    } catch (error) {
      // ignore: use_build_context_synchronously
      _showSnack(context, appErrorMessage(error, fallback: 'Не удалось отключить доступ врача.'));
    }
  }

  Future<void> _enableDoctorAccess(
    BuildContext context,
    WidgetRef ref,
    DoctorAdminModel doctor,
  ) async {
    try {
      await ref.read(adminRepositoryProvider).enableDoctorAccess(doctor.id);
      ref.invalidate(adminDoctorsProvider);
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Доступ врача включён');
    } catch (error) {
      // ignore: use_build_context_synchronously
      _showSnack(context, appErrorMessage(error, fallback: 'Не удалось включить доступ врача.'));
    }
  }

  Future<void> _showDoctorSheet(
    BuildContext context,
    WidgetRef ref,
    DoctorAdminModel doctor,
    List<ClinicAdminModel> clinics,
    ClinicAdminModel? currentClinic,
  ) async {
    String clinicQuery = '';

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final filteredClinics = clinicQuery.trim().isEmpty
                ? clinics
                : clinics.where((clinic) {
                    final text = [
                      clinic.shortName,
                      clinic.fullName,
                      clinic.ogrn,
                      clinic.address,
                      clinic.postalIndex?.toString(),
                      clinic.phone,
                      clinic.email,
                      clinic.chiefDoctorName,
                      clinic.deputyChiefDoctorName,
                    ].whereType<String>().join(' ').toLowerCase();
                    return text.contains(clinicQuery.trim().toLowerCase());
                  }).toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(sheetContext).size.height * 0.86,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        doctor.displayName,
                        style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        !doctor.isActive
                            ? 'Статус: доступ отключён'
                            : currentClinic == null
                                ? 'Клиника не назначена'
                                : 'Текущая клиника: ${currentClinic.shortName}',
                        style: const TextStyle(color: Color(0xFF607D78)),
                      ),
                      const SizedBox(height: 16),
                      if (!doctor.isActive) ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.of(sheetContext).pop('__enable_access__'),
                            child: const Text('Включить доступ'),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (clinics.isNotEmpty) ...[
                        Text(
                          doctor.isActive ? 'Назначить клинику' : 'Включить доступ и назначить клинику',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (value) => setSheetState(() => clinicQuery = value),
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: 'Поиск клиники',
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: (MediaQuery.of(sheetContext).size.height * 0.28).clamp(120.0, 260.0).toDouble(),
                          child: filteredClinics.isEmpty
                              ? const Center(child: Text('По запросу ничего не найдено'))
                              : ListView.separated(
                                  itemCount: filteredClinics.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final clinic = filteredClinics[index];
                                    return Card(
                                      child: ListTile(
                                        title: Text(clinic.shortName),
                                        subtitle: Text(
                                          clinic.fullName?.trim().isNotEmpty == true
                                              ? clinic.fullName!
                                              : 'Полное название не указано',
                                        ),
                                        trailing: clinic.id == currentClinic?.id ? const Text('Назначена') : null,
                                        onTap: () => Navigator.of(sheetContext).pop(clinic.id),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ] else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Клиник пока нет. Сначала создайте клинику.'),
                        ),
                      if (doctor.isActive && currentClinic != null) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop('__detach__'),
                            child: const Text('Отвязать от клиники'),
                          ),
                        ),
                      ],
                      if (doctor.isActive) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop('__disable_access__'),
                            child: const Text('Отключить доступ'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Отмена'),
                        ),
                      ),
                    ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (selected == null || !context.mounted) return;
    if (selected == '__enable_access__') {
      await _enableDoctorAccess(context, ref, doctor);
      return;
    }
    if (selected == '__detach__') {
      await _detach(context, ref, doctor);
      return;
    }
    if (selected == '__disable_access__') {
      await _disableDoctorAccess(context, ref, doctor);
      return;
    }

    final selectedClinic = clinics.firstWhere((clinic) => clinic.id == selected);
    await _assign(context, ref, doctor, selectedClinic);
  }

  Widget _buildSearchField({
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildClinicsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ClinicAdminModel>> clinicsAsync,
  ) {
    final query = ref.watch(adminClinicSearchProvider).trim().toLowerCase();

    return clinicsAsync.when(
      loading: () => const Card(child: ListTile(title: Text('Загрузка клиник...'))),
      error: (error, _) => Card(child: ListTile(title: Text(appLoadErrorMessage(error, fallback: 'Не удалось загрузить клиники.')))),
      data: (clinics) {
        final filteredClinics = query.isEmpty
            ? clinics
            : clinics.where((clinic) {
                final text = [
                  clinic.shortName,
                  clinic.fullName,
                  clinic.ogrn,
                  clinic.address,
                  clinic.postalIndex?.toString(),
                  clinic.phone,
                  clinic.email,
                  clinic.chiefDoctorName,
                  clinic.deputyChiefDoctorName,
                ].whereType<String>().join(' ').toLowerCase();
                return text.contains(query);
              }).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Клиники',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showClinicSheet(context, ref),
                      child: const Text('Создать'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSearchField(
                  hintText: 'Поиск клиники',
                  onChanged: (value) => ref.read(adminClinicSearchProvider.notifier).state = value,
                ),
                const SizedBox(height: 12),
                if (clinics.isEmpty)
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Клиники не найдены'),
                    subtitle: Text('Создайте клинику, чтобы привязывать к ней врачей.'),
                  )
                else if (filteredClinics.isEmpty)
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('По запросу ничего не найдено'),
                    subtitle: Text('Измените текст поиска.'),
                  )
                else
                  ...filteredClinics.map(
                    (clinic) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(clinic.shortName),
                      subtitle: Text(clinic.subtitle),
                      isThreeLine: clinic.subtitle.contains('\n'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showClinicSheet(context, ref, clinic: clinic);
                          } else if (value == 'delete') {
                            _deleteClinic(context, ref, clinic);
                          }
                        },
                        itemBuilder: (menuContext) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Редактировать'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Удалить'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDoctorsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ClinicAdminModel>> clinicsAsync,
    AsyncValue<List<DoctorAdminModel>> doctorsAsync,
  ) {
    final query = ref.watch(adminDoctorSearchProvider).trim().toLowerCase();

    return doctorsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: LoadingView(),
      ),
      error: (error, _) => Card(child: ListTile(title: Text(appLoadErrorMessage(error, fallback: 'Не удалось загрузить врачей.')))),
      data: (doctors) {
        if (doctors.isEmpty) {
          return const Card(
            child: ListTile(
              title: Text('Врачей пока нет'),
              subtitle: Text('После регистрации врача его профиль появится здесь.'),
            ),
          );
        }

        return clinicsAsync.when(
          loading: () => const Card(child: ListTile(title: Text('Загрузка клиник...'))),
          error: (error, _) => Card(child: ListTile(title: Text(appLoadErrorMessage(error, fallback: 'Не удалось загрузить клиники.')))),
          data: (clinics) {
            final sortedDoctors = [...doctors]..sort((a, b) {
                if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
                final aEmpty = !a.hasClinic;
                final bEmpty = !b.hasClinic;
                if (aEmpty != bEmpty) return aEmpty ? -1 : 1;
                return a.displayName.compareTo(b.displayName);
              });
            final waitingCount = sortedDoctors.where((doctor) => doctor.isActive && !doctor.hasClinic).length;
            final disabledCount = sortedDoctors.where((doctor) => !doctor.isActive).length;
            final filteredDoctors = query.isEmpty
                ? sortedDoctors
                : sortedDoctors.where((doctor) {
                    final matchingClinics = clinics.where((item) => item.id == doctor.clinicId).toList();
                    final ClinicAdminModel? clinic = matchingClinics.isEmpty ? null : matchingClinics.first;
                    final text = [
                      doctor.displayName,
                      doctor.statusText,
                      clinic?.shortName,
                      clinic?.fullName,
                    ].whereType<String>().join(' ').toLowerCase();
                    return text.contains(query);
                  }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Врачи',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ожидают привязки: $waitingCount · доступ отключён: $disabledCount',
                          style: const TextStyle(color: Color(0xFF607D78)),
                        ),
                        const SizedBox(height: 12),
                        _buildSearchField(
                          hintText: 'Поиск врача',
                          onChanged: (value) => ref.read(adminDoctorSearchProvider.notifier).state = value,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (filteredDoctors.isEmpty)
                  const Card(
                    child: ListTile(
                      title: Text('По запросу ничего не найдено'),
                      subtitle: Text('Измените текст поиска.'),
                    ),
                  )
                else
                  ...filteredDoctors.map((doctor) {
                    final matchingClinics = clinics.where((item) => item.id == doctor.clinicId).toList();
                    final ClinicAdminModel? clinic = matchingClinics.isEmpty ? null : matchingClinics.first;
                    final clinicText = clinic == null ? 'Клиника не назначена' : 'Клиника: ${clinic.shortName}';
                    final subtitle = doctor.isActive ? clinicText : 'Доступ отключён';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: ListTile(
                          title: Text(doctor.displayName),
                          subtitle: Text(subtitle),
                          trailing: TextButton(
                            onPressed: () => _showDoctorSheet(context, ref, doctor, clinics, clinic),
                            child: const Text('Действия'),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final clinicsAsync = ref.watch(adminClinicsProvider);
    final doctorsAsync = ref.watch(adminDoctorsProvider);

    return profileAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Администрирование')),
        body: Center(child: Text(appLoadErrorMessage(error, fallback: 'Не удалось загрузить профиль.'), textAlign: TextAlign.center)),
      ),
      data: (profile) {
        if (profile?.isAdmin != true) {
          return Scaffold(
            appBar: AppBar(title: const Text('Администрирование')),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Недостаточно прав. Этот раздел доступен только администратору.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Админ-панель'),
            actions: [
              IconButton(
                tooltip: 'Обновить',
                onPressed: () {
                  ref.invalidate(adminClinicsProvider);
                  ref.invalidate(adminDoctorsProvider);
                },
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: 'Выйти',
                onPressed: () => _signOut(context, ref),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Управление доступом',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Создавайте клиники, редактируйте их данные и управляйте доступом врачей.',
                          style: TextStyle(color: Color(0xFF607D78), height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildClinicsSection(context, ref, clinicsAsync),
                const SizedBox(height: 12),
                _buildDoctorsSection(context, ref, clinicsAsync, doctorsAsync),
              ],
            ),
          ),
        );
      },
    );
  }
}
