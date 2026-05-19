class ExaminationModel {
  final String id;
  final String patientId;
  final DateTime examDateTime;
  final String status;
  final String? doctorName;

  ExaminationModel({
    required this.id,
    required this.patientId,
    required this.examDateTime,
    required this.status,
    this.doctorName,
  });

  factory ExaminationModel.fromJson(Map<String, dynamic> json) {
    return ExaminationModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      examDateTime: DateTime.parse(json['exam_datetime'] as String),
      status: json['status'] as String,
      doctorName: json['doctor_name']?.toString(),
    );
  }
}
