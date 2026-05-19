class CurrentExaminationModel {
  final String id;
  final String patientId;
  final String patientName;
  final String cardNumber;
  final DateTime examDateTime;
  final String status;
  final String? doctorName;

  CurrentExaminationModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.cardNumber,
    required this.examDateTime,
    required this.status,
    this.doctorName,
  });

  factory CurrentExaminationModel.fromJson(Map<String, dynamic> json) {
    final patientRaw = json['patients'];
    final patient = patientRaw is Map ? Map<String, dynamic>.from(patientRaw) : <String, dynamic>{};
    final lastName = (patient['last_name'] ?? '').toString().trim();
    final firstName = (patient['first_name'] ?? '').toString().trim();
    final middleName = (patient['middle_name'] ?? '').toString().trim();
    final name = [lastName, firstName, middleName].where((part) => part.isNotEmpty).join(' ');

    return CurrentExaminationModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: name.isEmpty ? 'Пациент без ФИО' : name,
      cardNumber: (patient['card_number'] ?? '—').toString(),
      examDateTime: DateTime.parse(json['exam_datetime'] as String),
      status: json['status'] as String? ?? 'in_progress',
      doctorName: json['doctor_name']?.toString(),
    );
  }
}
