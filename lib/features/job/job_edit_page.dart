import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import 'job_model.dart';

class JobEditPage extends StatefulWidget {
  const JobEditPage({super.key, required this.post});
  final JobPost post;

  @override
  State<JobEditPage> createState() => _JobEditPageState();
}

class _JobEditPageState extends State<JobEditPage> {
  late final TextEditingController _title;
  late final TextEditingController _shop;
  late final TextEditingController _wage;
  late final TextEditingController _content;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.post.title);
    _shop = TextEditingController(text: widget.post.shopName);
    _wage = TextEditingController(text: widget.post.wage.toString());
    _content = TextEditingController(text: widget.post.content);
  }

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
    if (me == null) return;

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
      await state.jobs.updateFromForm(
        requesterId: me.userId,
        id: widget.post.id,
        title: title,
        shopName: shop,
        wage: wage,
        content: content,
      );
      if (!mounted) return;
      UiUtils.snack(context, '수정 완료');
      Navigator.pop(context);
    } catch (e) {
      UiUtils.snack(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '공고 수정',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: '제목')),
          const SizedBox(height: 10),
          TextField(controller: _shop, decoration: const InputDecoration(labelText: '가게명')),
          const SizedBox(height: 10),
          TextField(
            controller: _wage,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '시급'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _content,
            maxLines: 4,
            decoration: const InputDecoration(labelText: '내용'),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: _loading ? '처리중...' : '저장',
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
