class ClinicAdminModel {
  final String id;
  final String shortName;
  final String? fullName;
  final String? ogrn;
  final String? address;
  final String? phone;
  final String? email;
  final int? postalIndex;
  final String? chiefDoctorName;
  final String? deputyChiefDoctorName;

  ClinicAdminModel({
    required this.id,
    required this.shortName,
    this.fullName,
    this.ogrn,
    this.address,
    this.phone,
    this.email,
    this.postalIndex,
    this.chiefDoctorName,
    this.deputyChiefDoctorName,
  });

  factory ClinicAdminModel.fromJson(Map<String, dynamic> json) {
    return ClinicAdminModel(
      id: json['id'] as String,
      shortName: json['short_name'] as String? ?? 'Без названия',
      fullName: json['full_name'] as String?,
      ogrn: json['ogrn'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      postalIndex: (json['postal_index'] as num?)?.toInt(),
      chiefDoctorName: json['chief_doctor_name'] as String?,
      deputyChiefDoctorName: json['deputy_chief_doctor_name'] as String?,
    );
  }

  String get title {
    final full = fullName?.trim();
    if (full == null || full.isEmpty || full == shortName) return shortName;
    return '$shortName — $full';
  }

  String get subtitle {
    final parts = <String>[];
    final full = fullName?.trim();
    final ogrnValue = ogrn?.trim();
    final addressValue = address?.trim();
    final phoneValue = phone?.trim();
    final emailValue = email?.trim();
    final chiefValue = chiefDoctorName?.trim();

    if (full != null && full.isNotEmpty && full != shortName) parts.add(full);
    if (ogrnValue != null && ogrnValue.isNotEmpty) parts.add('ОГРН: $ogrnValue');
    if (addressValue != null && addressValue.isNotEmpty) parts.add(addressValue);
    if (postalIndex != null) parts.add('Индекс: $postalIndex');
    if (phoneValue != null && phoneValue.isNotEmpty) parts.add(phoneValue);
    if (emailValue != null && emailValue.isNotEmpty) parts.add(emailValue);
    if (chiefValue != null && chiefValue.isNotEmpty) parts.add('Главный врач: $chiefValue');

    if (parts.isEmpty) return 'Дополнительные данные не указаны';
    return parts.join('\n');
  }
}

class DoctorAdminModel {
  final String id;
  final String? fullName;
  final String? clinicId;
  final String? doctorId;
  final bool isActive;

  DoctorAdminModel({
    required this.id,
    this.fullName,
    this.clinicId,
    this.doctorId,
    this.isActive = true,
  });

  factory DoctorAdminModel.fromJson(Map<String, dynamic> json) {
    return DoctorAdminModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      clinicId: json['clinic_id'] as String?,
      doctorId: json['doctor_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String get displayName {
    final value = fullName?.trim();
    if (value != null && value.isNotEmpty) return value;
    return 'Врач без ФИО';
  }

  bool get hasClinic => clinicId != null && clinicId!.trim().isNotEmpty;

  String get statusText {
    if (!isActive) return 'Доступ отключён';
    if (!hasClinic) return 'Ожидает привязки';
    return 'Активен';
  }
}
