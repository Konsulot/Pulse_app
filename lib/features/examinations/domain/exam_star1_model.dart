class ExamStar1Model {
  final String examinationId;

  final int p1;
  final int p2;
  final int p3;
  final int p4;

  final int rp1;
  final int rp2;
  final int rp3;
  final int rp4;

  final int r1;
  final int r2;
  final int r3;
  final int r4;

  final int gi1;
  final int gi2;
  final int gi3;
  final int gi4;

  final int e1;
  final int e2;
  final int e3;
  final int e4;

  final int vb1;
  final int vb2;
  final int vb3;
  final int vb4;

  final int v1;
  final int v2;
  final int v3;
  final int v4;

  final int c1;
  final int c2;
  final int c3;
  final int c4;

  final int f1;
  final int f2;
  final int f3;
  final int f4;

  final int ig1;
  final int ig2;
  final int ig3;
  final int ig4;

  ExamStar1Model({
    required this.examinationId,
    required this.p1,
    required this.p2,
    required this.p3,
    required this.p4,
    required this.rp1,
    required this.rp2,
    required this.rp3,
    required this.rp4,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.r4,
    required this.gi1,
    required this.gi2,
    required this.gi3,
    required this.gi4,
    required this.e1,
    required this.e2,
    required this.e3,
    required this.e4,
    required this.vb1,
    required this.vb2,
    required this.vb3,
    required this.vb4,
    required this.v1,
    required this.v2,
    required this.v3,
    required this.v4,
    required this.c1,
    required this.c2,
    required this.c3,
    required this.c4,
    required this.f1,
    required this.f2,
    required this.f3,
    required this.f4,
    required this.ig1,
    required this.ig2,
    required this.ig3,
    required this.ig4,
  });

  Map<String, dynamic> toInsertJson() => {
        'examination_id': examinationId,
        'p1': p1,
        'p2': p2,
        'p3': p3,
        'p4': p4,
        'rp1': rp1,
        'rp2': rp2,
        'rp3': rp3,
        'rp4': rp4,
        'r1': r1,
        'r2': r2,
        'r3': r3,
        'r4': r4,
        'gi1': gi1,
        'gi2': gi2,
        'gi3': gi3,
        'gi4': gi4,
        'e1': e1,
        'e2': e2,
        'e3': e3,
        'e4': e4,
        'vb1': vb1,
        'vb2': vb2,
        'vb3': vb3,
        'vb4': vb4,
        'v1': v1,
        'v2': v2,
        'v3': v3,
        'v4': v4,
        'c1': c1,
        'c2': c2,
        'c3': c3,
        'c4': c4,
        'f1': f1,
        'f2': f2,
        'f3': f3,
        'f4': f4,
        'ig1': ig1,
        'ig2': ig2,
        'ig3': ig3,
        'ig4': ig4,
      };
}
