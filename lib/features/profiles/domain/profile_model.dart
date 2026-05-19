class ProfileModel {
  final String id;
  final String role;
  final String? fullName;
  final String? clinicId;
  final String? doctorId;
  final bool isActive;

  ProfileModel({
    required this.id,
    required this.role,
    this.fullName,
    this.clinicId,
    this.doctorId,
    this.isActive = true,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      role: json['role'] as String,
      fullName: json['full_name'] as String?,
      clinicId: json['clinic_id'] as String?,
      doctorId: json['doctor_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String get displayName => fullName != null && fullName!.trim().isNotEmpty ? fullName! : role;

  bool get isAdmin => role.toLowerCase().trim() == 'admin';

  bool get isDoctor => role.toLowerCase().trim() == 'doctor';

  bool get hasClinic => clinicId != null && clinicId!.trim().isNotEmpty;
}
