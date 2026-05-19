class PatientModel {
  final String id;
  final String cardNumber;
  final String lastName;
  final String firstName;
  final String? middleName;
  final DateTime? birthDate;
  final String? clinicId;
  final String? polis;
  final String? snils;
  final int? genderId;
  final String? region;
  final String? city;
  final String? street;
  final int? house;
  final int? room;
  final int? postalIndex;
  final String? job;
  final String? jobTitle;
  final bool? isDisabled;
  final int? insuranceOrg;
  final String? insuranceOrgName;
  final int? study;
  final String? education;
  final int? disabilityGroup;

  PatientModel({
    required this.id,
    required this.cardNumber,
    required this.lastName,
    required this.firstName,
    this.middleName,
    this.birthDate,
    this.clinicId,
    this.polis,
    this.snils,
    this.genderId,
    this.region,
    this.city,
    this.street,
    this.house,
    this.room,
    this.postalIndex,
    this.job,
    this.jobTitle,
    this.isDisabled,
    this.insuranceOrg,
    this.insuranceOrgName,
    this.study,
    this.education,
    this.disabilityGroup,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final legacyInsuranceOrg = (json['insurance_org'] as num?)?.toInt();
    final legacyStudy = (json['study'] as num?)?.toInt();

    return PatientModel(
      id: json['id'] as String,
      cardNumber: json['card_number'] as String,
      lastName: json['last_name'] as String,
      firstName: json['first_name'] as String,
      middleName: json['middle_name'] as String?,
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date'] as String) : null,
      clinicId: json['clinic_id'] as String?,
      polis: json['polis'] as String?,
      snils: json['snils'] as String?,
      genderId: (json['gender_id'] as num?)?.toInt(),
      region: json['region'] as String?,
      city: json['city'] as String?,
      street: json['street'] as String?,
      house: (json['house'] as num?)?.toInt(),
      room: (json['room'] as num?)?.toInt(),
      postalIndex: (json['postal_index'] as num?)?.toInt(),
      job: json['job'] as String?,
      jobTitle: json['job_title'] as String?,
      isDisabled: json['is_disabled'] as bool?,
      insuranceOrg: legacyInsuranceOrg,
      insuranceOrgName: json['insurance_org_name'] as String? ?? legacyInsuranceOrg?.toString(),
      study: legacyStudy,
      education: json['education'] as String? ?? legacyStudy?.toString(),
      disabilityGroup: (json['disability_group'] as num?)?.toInt(),
    );
  }

  String get fullName => [
        lastName,
        firstName,
        if (middleName != null && middleName!.trim().isNotEmpty) middleName!,
      ].join(' ');

  String get genderText {
    switch (genderId) {
      case 1:
        return 'Мужской';
      case 2:
        return 'Женский';
      default:
        return '—';
    }
  }
}
