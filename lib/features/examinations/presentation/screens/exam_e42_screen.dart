import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/exam_e42_model.dart';
import '../controllers/examination_controller.dart';
import '../widgets/exam_exit_button.dart';
import '../../../../core/errors/app_error_message.dart';

class ExamE42Screen extends ConsumerStatefulWidget {
  final String examinationId;
  final String? from;
  const ExamE42Screen({super.key, required this.examinationId, this.from});

  @override
  ConsumerState<ExamE42Screen> createState() => _ExamE42ScreenState();
}

class _ExamE42ScreenState extends ConsumerState<ExamE42Screen> {
  bool get _isEditMode => widget.from == 'result';
  String _chiCunLeft = 'Вэй';
  String _e42Left = 'Вэй';
  String _chiCunRight = 'Вэй';
  String _e42Right = 'Вэй';
  bool _seeded = false;

  List<DropdownMenuItem<String>> get _items => const [
    DropdownMenuItem(value: 'Вэй', child: Text('Вэй')),
    DropdownMenuItem(value: 'Чжун', child: Text('Чжун')),
  ];

  String _normalizeE42Value(String? value) {
    return value == 'Чжун' ? 'Чжун' : 'Вэй';
  }

  void _seed(Map<String, dynamic>? data) {
    if (_seeded || data == null) return;
    _seeded = true;
    _chiCunLeft = _normalizeE42Value(data['chi_cun_left'] as String?);
    _e42Left = _normalizeE42Value(data['e42_left'] as String?);
    _chiCunRight = _normalizeE42Value(data['chi_cun_right'] as String?);
    _e42Right = _normalizeE42Value(data['e42_right'] as String?);
  }

  Future<void> _save() async {
    final model = ExamE42Model(
      examinationId: widget.examinationId,
      chiCunLeft: _chiCunLeft,
      e42Left: _e42Left,
      chiCunRight: _chiCunRight,
      e42Right: _e42Right,
    );

    await ref.read(saveE42ControllerProvider.notifier).save(model);
    final state = ref.read(saveE42ControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorMessage(state.error, duringExamination: true))));
      return;
    }
    if (mounted) {
      if (_isEditMode) {
        context.go('/examinations/${widget.examinationId}/result');
      } else {
        context.push('/examinations/${widget.examinationId}/foot');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saveE42ControllerProvider);
    final existingAsync = ref.watch(e42DataProvider(widget.examinationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('E42'),
        actions: [ExamExitButton(examinationId: widget.examinationId)],
      ),
      body: existingAsync.when(
        data: (data) {
          _seed(data);
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
            child: ListView(
              children: [
                DropdownButtonFormField<String>(initialValue: _chiCunLeft, decoration: const InputDecoration(labelText: 'chi_cun_left'), items: _items, onChanged: (v) { if (v != null) setState(() => _chiCunLeft = v); }),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(initialValue: _e42Left, decoration: const InputDecoration(labelText: 'e42_left'), items: _items, onChanged: (v) { if (v != null) setState(() => _e42Left = v); }),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(initialValue: _chiCunRight, decoration: const InputDecoration(labelText: 'chi_cun_right'), items: _items, onChanged: (v) { if (v != null) setState(() => _chiCunRight = v); }),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(initialValue: _e42Right, decoration: const InputDecoration(labelText: 'e42_right'), items: _items, onChanged: (v) { if (v != null) setState(() => _e42Right = v); }),
                const SizedBox(height: 16),
                AppButton(title: 'Сохранить E42', isLoading: state.isLoading, onPressed: _save),
              ],
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(appLoadErrorMessage(e), textAlign: TextAlign.center)),
      ),
    );
  }
}
