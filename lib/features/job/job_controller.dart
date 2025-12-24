import 'package:flutter/foundation.dart';
import 'job_api.dart';
import 'job_model.dart';

class JobController extends ChangeNotifier {
  final _api = JobApi();

  List<JobPost> _items = [];
  List<JobPost> get items => _items;

  Future<void> refresh() async {
    _items = await _api.list();
    notifyListeners();
  }

  Future<void> create(JobPost post) async {
    // 이 메서드는 직접 쓰기보다 createFromForm 형태를 쓰는 것을 권장
    _items = [post, ..._items];
    notifyListeners();
  }

  Future<JobPost> createFromForm({
    required String employerId,
    required String title,
    required String shopName,
    required int wage,
    required String content,
  }) async {
    final created = await _api.create(
      employerId: employerId,
      title: title,
      shopName: shopName,
      wage: wage,
      content: content,
    );
    await refresh();
    return created;
  }

  Future<JobPost> updateFromForm({
    required String requesterId,
    required String id,
    required String title,
    required String shopName,
    required int wage,
    required String content,
  }) async {
    final updated = await _api.update(
      requesterId: requesterId,
      id: id,
      title: title,
      shopName: shopName,
      wage: wage,
      content: content,
    );
    await refresh();
    return updated;
  }

  Future<void> delete({
    required String requesterId,
    required String id,
  }) async {
    await _api.delete(requesterId: requesterId, id: id);
    await refresh();
  }
}
