class ResultInfoData {
  final int lung;
  final int hearth;
  final int spleen;
  final int liver;
  final int pericardium;
  final int kidney;
  final int thelargeintestine;
  final int thesmallintestine;
  final int stomach;
  final int gallbladder;
  final int tr;
  final int bladder;

  const ResultInfoData({
    required this.lung,
    required this.hearth,
    required this.spleen,
    required this.liver,
    required this.pericardium,
    required this.kidney,
    required this.thelargeintestine,
    required this.thesmallintestine,
    required this.stomach,
    required this.gallbladder,
    required this.tr,
    required this.bladder,
  });

  Map<String, int> toChannelMap() => {
        'p': lung,
        'c': hearth,
        'rp': spleen,
        'f': liver,
        'mc': pericardium,
        'r': kidney,
        'gi': thelargeintestine,
        'ig': thesmallintestine,
        'e': stomach,
        'vb': gallbladder,
        'tr': tr,
        'v': bladder,
      };
}
