import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';

class JobRegisterPage extends StatefulWidget {
  const JobRegisterPage({super.key});

  @override
  State<JobRegisterPage> createState() => _JobRegisterPageState();
}

class _JobRegisterPageState extends State<JobRegisterPage> {
  final _title = TextEditingController();
  final _shop = TextEditingController();
  final _wage = TextEditingController();
  final _content = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _title.dispose();
    _shop.dispose();
    _wage.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = AppScope.of(context);
    final me = state.auth.me;
    if (me == null) {
      UiUtils.snack(context, '로그인이 필요합니다.');
      return;
    }

    final title = _title.text.trim();
    final shop = _shop.text.trim();
    final wage = UiUtils.tryParseInt(_wage.text);
    final content = _content.text.trim();

    if (title.isEmpty || shop.isEmpty || wage == null) {
      UiUtils.snack(context, '제목/가게/시급(숫자)을 확인하세요.');
      return;
    }

    setState(() => _loading = true);
    try {
      await state.jobs.createFromForm(
        employerId: me.userId,
        title: title,
        shopName: shop,
        wage: wage,
        content: content,
      );

      if (!mounted) return;
      UiUtils.snack(context, '공고 등록 완료');
      Navigator.pop(context); // 목록으로 복귀
    } catch (e) {
      if (!mounted) return;
      UiUtils.snack(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '공고 등록',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: '제목'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _shop,
            decoration: const InputDecoration(labelText: '가게명'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _wage,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '시급(숫자)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _content,
            maxLines: 4,
            decoration: const InputDecoration(labelText: '내용(선택)'),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: _loading ? '처리중...' : '등록',
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
