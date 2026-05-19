class ExamE42Model {
  final String examinationId;
  final String chiCunLeft;
  final String e42Left;
  final String chiCunRight;
  final String e42Right;
  final Map<String, dynamic>? selectedCells;

  ExamE42Model({
    required this.examinationId,
    required this.chiCunLeft,
    required this.e42Left,
    required this.chiCunRight,
    required this.e42Right,
    this.selectedCells,
  });

  Map<String, dynamic> toInsertJson() => {
        'examination_id': examinationId,
        'chi_cun_left': chiCunLeft,
        'e42_left': e42Left,
        'chi_cun_right': chiCunRight,
        'e42_right': e42Right,
        'selected_cells': selectedCells,
      };
}
