class ExamStar2Model {
  final String examinationId;

  final int mc1;
  final int mc2;
  final int mc3;
  final int mc4;
  final int mc5;

  final int tr1;
  final int tr2;
  final int tr3;
  final int tr4;
  final int tr5;

  final int r5;
  final int gi5;
  final int e5;
  final int vb5;
  final int v5;
  final int c5;
  final int f5;
  final int ig5;
  final int p5;
  final int rp5;

  ExamStar2Model({
    required this.examinationId,
    required this.mc1,
    required this.mc2,
    required this.mc3,
    required this.mc4,
    required this.mc5,
    required this.tr1,
    required this.tr2,
    required this.tr3,
    required this.tr4,
    required this.tr5,
    required this.r5,
    required this.gi5,
    required this.e5,
    required this.vb5,
    required this.v5,
    required this.c5,
    required this.f5,
    required this.ig5,
    required this.p5,
    required this.rp5,
  });

  Map<String, dynamic> toInsertJson() => {
        'examination_id': examinationId,
        'mc1': mc1,
        'mc2': mc2,
        'mc3': mc3,
        'mc4': mc4,
        'mc5': mc5,
        'tr1': tr1,
        'tr2': tr2,
        'tr3': tr3,
        'tr4': tr4,
        'tr5': tr5,
        'r5': r5,
        'gi5': gi5,
        'e5': e5,
        'vb5': vb5,
        'v5': v5,
        'c5': c5,
        'f5': f5,
        'ig5': ig5,
        'p5': p5,
        'rp5': rp5,
      };
}
