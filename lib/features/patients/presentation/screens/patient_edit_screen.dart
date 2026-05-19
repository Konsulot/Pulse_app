import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_message.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/russian_date_input_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/patient_model.dart';
import '../controllers/patients_controller.dart';

class PatientEditScreen extends ConsumerStatefulWidget {
  final String patientId;
  const PatientEditScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientEditScreen> createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends ConsumerState<PatientEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _polisController = TextEditingController();
  final _snilsController = TextEditingController();
  final _regionController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseController = TextEditingController();
  final _roomController = TextEditingController();
  final _postalIndexController = TextEditingController();
  final _jobController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _insuranceOrgController = TextEditingController();
  final _educationController = TextEditingController();
  final _disabilityGroupController = TextEditingController();

  int? _genderId;
  bool? _isDisabled;
  bool _seeded = false;

  @override
  void dispose() {
    _cardController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _birthDateController.dispose();
    _polisController.dispose();
    _snilsController.dispose();
    _regionController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _houseController.dispose();
    _roomController.dispose();
    _postalIndexController.dispose();
    _jobController.dispose();
    _jobTitleController.dispose();
    _insuranceOrgController.dispose();
    _educationController.dispose();
    _disabilityGroupController.dispose();
    super.dispose();
  }

  void _seed(PatientModel patient) {
    if (_seeded) return;
    _seeded = true;
    _cardController.text = patient.cardNumber;
    _lastNameController.text = patient.lastName;
    _firstNameController.text = patient.firstName;
    _middleNameController.text = patient.middleName ?? '';
    _birthDateController.text = AppDateUtils.formatRussianDate(patient.birthDate);
    _polisController.text = patient.polis ?? '';
    _snilsController.text = patient.snils ?? '';
    _genderId = patient.genderId;
    _regionController.text = patient.region ?? '';
    _cityController.text = patient.city ?? '';
    _streetController.text = patient.street ?? '';
    _houseController.text = patient.house?.toString() ?? '';
    _roomController.text = patient.room?.toString() ?? '';
    _postalIndexController.text = patient.postalIndex?.toString() ?? '';
    _jobController.text = patient.job ?? '';
    _jobTitleController.text = patient.jobTitle ?? '';
    _isDisabled = patient.isDisabled;
    _insuranceOrgController.text = patient.insuranceOrgName ?? '';
    _educationController.text = patient.education ?? '';
    _disabilityGroupController.text = patient.disabilityGroup?.toString() ?? '';
  }

  int? _intValue(TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }

  String? _disabilityGroupValidator(String? value) {
    if (_isDisabled != true) return null;
    final required = Validators.requiredField(value, label: 'Группа инвалидности');
    if (required != null) return required;
    return Validators.intRange(value, label: 'Группа инвалидности', min: 1, max: 3);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final birthDate = AppDateUtils.tryParseRussianDate(_birthDateController.text);
    final disabilityGroup = _isDisabled == true ? _intValue(_disabilityGroupController) : null;

    await ref.read(updatePatientControllerProvider.notifier).updatePatient(
          id: widget.patientId,
          cardNumber: _cardController.text.trim(),
          lastName: _lastNameController.text.trim(),
          firstName: _firstNameController.text.trim(),
          middleName: _middleNameController.text.trim(),
          birthDate: birthDate,
          polis: _polisController.text.trim(),
          snils: _snilsController.text.trim(),
          genderId: _genderId,
          region: _regionController.text.trim(),
          city: _cityController.text.trim(),
          street: _streetController.text.trim(),
          house: _intValue(_houseController),
          room: _intValue(_roomController),
          postalIndex: _intValue(_postalIndexController),
          job: _jobController.text.trim(),
          jobTitle: _jobTitleController.text.trim(),
          isDisabled: _isDisabled,
          insuranceOrgName: _insuranceOrgController.text.trim(),
          education: _educationController.text.trim(),
          disabilityGroup: disabilityGroup,
        );
    final state = ref.read(updatePatientControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error))));
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 12);

  @override
  Widget build(BuildContext context) {
    final patientAsync = ref.watch(patientDetailsProvider(widget.patientId));
    final state = ref.watch(updatePatientControllerProvider);
    final intFormatters = [FilteringTextInputFormatter.digitsOnly];
    final postalIndexFormatters = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)];
    final snilsFormatters = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)];
    final polisFormatters = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(20)];

    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать пациента')),
      body: patientAsync.when(
        data: (patient) {
          _seed(patient);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _section(
                    title: 'Основные данные',
                    children: [
                      AppTextField(controller: _cardController, label: 'Номер карты *', validator: Validators.cardNumber),
                      _gap(),
                      AppTextField(controller: _lastNameController, label: 'Фамилия *', validator: (v) => Validators.personName(v, label: 'Фамилия', required: true)),
                      _gap(),
                      AppTextField(controller: _firstNameController, label: 'Имя *', validator: (v) => Validators.personName(v, label: 'Имя', required: true)),
                      _gap(),
                      AppTextField(controller: _middleNameController, label: 'Отчество', validator: (v) => Validators.personName(v, label: 'Отчество')),
                      _gap(),
                      AppTextField(
                        controller: _birthDateController,
                        label: 'Дата рождения',
                        keyboardType: TextInputType.number,
                        inputFormatters: [RussianDateInputFormatter()],
                        validator: AppDateUtils.validateRussianBirthDate,
                      ),
                      _gap(),
                      DropdownButtonFormField<int?>(
                        initialValue: _genderId,
                        decoration: const InputDecoration(labelText: 'Пол'),
                        items: const [
                          DropdownMenuItem<int?>(value: null, child: Text('Не указан')),
                          DropdownMenuItem<int?>(value: 1, child: Text('Мужской')),
                          DropdownMenuItem<int?>(value: 2, child: Text('Женский')),
                        ],
                        onChanged: (value) => setState(() => _genderId = value),
                      ),
                    ],
                  ),
                  _section(
                    title: 'Документы',
                    children: [
                      AppTextField(controller: _polisController, label: 'Полис', keyboardType: TextInputType.number, inputFormatters: polisFormatters, validator: Validators.polis),
                      _gap(),
                      AppTextField(controller: _snilsController, label: 'СНИЛС', keyboardType: TextInputType.number, inputFormatters: snilsFormatters, validator: Validators.snils),
                      _gap(),
                      AppTextField(controller: _insuranceOrgController, label: 'Страховая медицинская организация', validator: (v) => Validators.optionalText(v, label: 'Страховая медицинская организация', maxLength: 160)),
                    ],
                  ),
                  _section(
                    title: 'Адрес',
                    children: [
                      AppTextField(controller: _postalIndexController, label: 'Почтовый индекс', keyboardType: TextInputType.number, inputFormatters: postalIndexFormatters, validator: Validators.postalIndex),
                      _gap(),
                      AppTextField(controller: _regionController, label: 'Регион/область', validator: (v) => Validators.optionalText(v, label: 'Регион/область')),
                      _gap(),
                      AppTextField(controller: _cityController, label: 'Населённый пункт', validator: (v) => Validators.optionalText(v, label: 'Населённый пункт')),
                      _gap(),
                      AppTextField(controller: _streetController, label: 'Улица', validator: (v) => Validators.optionalText(v, label: 'Улица')),
                      _gap(),
                      AppTextField(controller: _houseController, label: 'Дом', keyboardType: TextInputType.number, inputFormatters: intFormatters, validator: (v) => Validators.positiveInt(v, label: 'Дом', max: 9999)),
                      _gap(),
                      AppTextField(controller: _roomController, label: 'Квартира', keyboardType: TextInputType.number, inputFormatters: intFormatters, validator: (v) => Validators.positiveInt(v, label: 'Квартира', max: 99999)),
                    ],
                  ),
                  _section(
                    title: 'Дополнительно',
                    children: [
                      AppTextField(controller: _jobController, label: 'Место работы', validator: (v) => Validators.optionalText(v, label: 'Место работы')),
                      _gap(),
                      AppTextField(controller: _jobTitleController, label: 'Должность', validator: (v) => Validators.optionalText(v, label: 'Должность')),
                      _gap(),
                      AppTextField(controller: _educationController, label: 'Образование', validator: (v) => Validators.optionalText(v, label: 'Образование')),
                      _gap(),
                      DropdownButtonFormField<bool?>(
                        initialValue: _isDisabled,
                        decoration: const InputDecoration(labelText: 'Инвалидность'),
                        items: const [
                          DropdownMenuItem<bool?>(value: null, child: Text('Не указано')),
                          DropdownMenuItem<bool?>(value: false, child: Text('Нет')),
                          DropdownMenuItem<bool?>(value: true, child: Text('Да')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _isDisabled = value;
                            if (value != true) _disabilityGroupController.clear();
                          });
                        },
                      ),
                      if (_isDisabled == true) ...[
                        _gap(),
                        AppTextField(
                          controller: _disabilityGroupController,
                          label: 'Группа инвалидности *',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)],
                          validator: _disabilityGroupValidator,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(title: 'Сохранить изменения', isLoading: state.isLoading, onPressed: _submit),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(appLoadErrorMessage(e), textAlign: TextAlign.center)),
      ),
    );
  }
}
