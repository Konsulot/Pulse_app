class ExamEnergyModel {
  final String examinationId;
  final String result;
  final Map<String, dynamic>? selectedCells;

  ExamEnergyModel({
    required this.examinationId,
    required this.result,
    this.selectedCells,
  });

  Map<String, dynamic> toInsertJson() => {
        'examination_id': examinationId,
        'result': result,
        'selected_cells': selectedCells,
      };
}
