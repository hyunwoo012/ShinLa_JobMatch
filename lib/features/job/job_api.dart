import '../../core/common/utils.dart';
import '../auth/auth_model.dart';
import 'job_model.dart';

/// MockServer 역할을 하는 In-memory API
class JobApi {
  static final List<JobPost> _jobs = [
    JobPost(
      id: '1',
      title: '카페 알바 구합니다',
      shopName: '신라카페',
      wage: 10000,
      content: '주말 오후 가능자 우대',
      employerId: 'seed_employer',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<JobPost>> list() async {
    _jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(_jobs);
  }

  Future<JobPost> create({
    required String employerId,
    required String title,
    required String shopName,
    required int wage,
    required String content,
  }) async {
    final post = JobPost(
      id: UiUtils.newId(),
      title: title,
      shopName: shopName,
      wage: wage,
      content: content,
      employerId: employerId,
      createdAt: DateTime.now(),
    );
    _jobs.add(post);
    return post;
  }

  Future<JobPost> update({
    required String requesterId,
    required String id,
    required String title,
    required String shopName,
    required int wage,
    required String content,
  }) async {
    final idx = _jobs.indexWhere((e) => e.id == id);
    if (idx < 0) throw Exception('게시글이 없습니다.');
    final cur = _jobs[idx];
    if (cur.employerId != requesterId) throw Exception('수정 권한이 없습니다.');
    final updated = cur.copyWith(title: title, shopName: shopName, wage: wage, content: content);
    _jobs[idx] = updated;
    return updated;
  }

  Future<void> delete({
    required String requesterId,
    required String id,
  }) async {
    final idx = _jobs.indexWhere((e) => e.id == id);
    if (idx < 0) throw Exception('게시글이 없습니다.');
    if (_jobs[idx].employerId != requesterId) throw Exception('삭제 권한이 없습니다.');
    _jobs.removeAt(idx);
  }
}
