class ExamFootModel {
  final String examinationId;
  final String footStatus;
  final Map<String, dynamic>? selectedCells;

  ExamFootModel({
    required this.examinationId,
    required this.footStatus,
    this.selectedCells,
  });

  Map<String, dynamic> toInsertJson() => {
        'examination_id': examinationId,
        'foot_status': footStatus,
        'selected_cells': selectedCells,
      };
}
