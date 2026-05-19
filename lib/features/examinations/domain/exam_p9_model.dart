class ExamP9Model {
  final String examinationId;
  final String result;
  final String? direction;
  ExamP9Model({required this.examinationId, required this.result, this.direction});
  Map<String, dynamic> toInsertJson() => {
    'examination_id': examinationId,
    'result': result,
    'direction': direction,
  };
}
