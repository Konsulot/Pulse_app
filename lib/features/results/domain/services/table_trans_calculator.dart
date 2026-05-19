import '../models/result_info_data.dart';
import '../models/table_trans_result.dart';

class TableTransCalculator {
  const TableTransCalculator();

  TableTransResult calculate(ResultInfoData info) {
    final circleIds = <String>[
      'p${info.lung}',
      'c${info.hearth}',
      'rp${info.spleen}',
      'f${info.liver}',
      'mc${info.pericardium}',
      'r${info.kidney}',
      'gi${info.thelargeintestine}',
      'ig${info.thesmallintestine}',
      'e${info.stomach}',
      'vb${info.gallbladder}',
      'tr${info.tr}',
      'v${info.bladder}',
    ];

    final crossIds = List<String>.from(circleIds);

    int reverseStep(int value) => 4 - value;

    final balanceValues = <int?>[
      info.lung - reverseStep(info.thelargeintestine),
      info.hearth - reverseStep(info.thesmallintestine),
      info.spleen - reverseStep(info.stomach),
      info.liver - reverseStep(info.gallbladder),
      info.pericardium - reverseStep(info.tr),
      info.kidney - reverseStep(info.bladder),
    ];

    return TableTransResult(
      circleIds: circleIds,
      crossIds: crossIds,
      balanceValues: balanceValues,
    );
  }
}
