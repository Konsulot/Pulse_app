class DoctorProfileModel {
  final String? doctorId;
  final String? profileId;
  final String lastName;
  final String firstName;
  final String? middleName;
  final String? specialization;
  final DateTime? birthDate;
  final String? clinicId;

  DoctorProfileModel({
    this.doctorId,
    this.profileId,
    required this.lastName,
    required this.firstName,
    this.middleName,
    this.specialization,
    this.birthDate,
    this.clinicId,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return DoctorProfileModel(
      doctorId: json['id'] as String?,
      profileId: json['profile_id'] as String?,
      lastName: json['last_name'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      middleName: json['middle_name'] as String?,
      specialization: json['specialization'] as String?,
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date'] as String) : null,
      clinicId: json['clinic_id'] as String?,
    );
  }

  String get fullName => [
        lastName,
        firstName,
        if (middleName != null && middleName!.trim().isNotEmpty) middleName!,
      ].join(' ').trim();
}
