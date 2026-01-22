import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'profile_api.dart';
import 'profile_model.dart';

class ProfileController extends ChangeNotifier {
  final ProfileApi _api;
  ProfileController(this._api);

  StudentProfile? _myStudentProfile;
  StudentProfile? get myStudentProfile => _myStudentProfile;

  // ✅ 앱-only: "지원자(학생) 프로필" 캐시 (회사 화면에서 조회용)
  final Map<int, StudentProfile> _studentCache = {};
  List<StudentProfile> get cachedStudentProfiles =>
      _studentCache.values.toList()..sort((a, b) => a.userId.compareTo(b.userId));

  void _cacheStudent(StudentProfile p) {
    _studentCache[p.userId] = p;
  }

  StudentProfile? getCachedStudentProfile(int userId) => _studentCache[userId];

  /// 기존: 서버에서 내 학생 프로필 로드
  Future<void> loadMyStudentProfile() async {
    _myStudentProfile = await _api.getMyStudentProfile();

    // ✅ 로드된 내 프로필은 캐시에 저장 (회사 화면 데모용)
    if (_myStudentProfile != null) _cacheStudent(_myStudentProfile!);

    notifyListeners();
  }

  /// 기존: 서버에 내 학생 프로필 저장(기본 필드)
  /// - 링크/문서 업로드는 서버 준비 후 확장 예정
  Future<StudentProfile> saveMyStudentProfile({
    required String name,
    String? school,
    String? major,
    required List<String> skills,
    String? availableTime,
  }) async {
    final saved = await _api.upsertMyStudentProfile(
      name: name,
      school: school,
      major: major,
      skills: skills,
      availableTime: availableTime,
    );

    // ✅ 서버 응답에 링크/문서가 아직 없을 수 있으니
    // 기존 앱 상태에 들어있던 링크/문서를 보존하도록 병합
    final prev = _myStudentProfile;
    _myStudentProfile = saved.copyWith(
      githubUrl: prev?.githubUrl,
      portfolioUrl: prev?.portfolioUrl,
      linkedinUrl: prev?.linkedinUrl,
      notionUrl: prev?.notionUrl,
      documents: prev?.documents,
    );

    // ✅ 저장 후 캐시에도 업데이트
    if (_myStudentProfile != null) _cacheStudent(_myStudentProfile!);

    notifyListeners();
    return _myStudentProfile!;
  }

  /// ✅ 앱에서만: 링크 상태 반영(서버 붙기 전 단계)
  void setLinksLocal({
    String? githubUrl,
    String? portfolioUrl,
    String? linkedinUrl,
    String? notionUrl,
  }) {
    final p = _myStudentProfile;
    if (p == null) return;

    _myStudentProfile = p.copyWith(
      githubUrl: githubUrl,
      portfolioUrl: portfolioUrl,
      linkedinUrl: linkedinUrl,
      notionUrl: notionUrl,
    );

    // ✅ 캐시에도 반영
    _cacheStudent(_myStudentProfile!);

    notifyListeners();
  }

  /// ✅ 앱에서만: 파일 선택(업로드는 아직 X)
  Future<PlatformFile?> pickDocumentFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      withData: false,
    );
    if (res == null || res.files.isEmpty) return null;
    return res.files.single;
  }

  /// ✅ 앱에서만: 선택한 파일을 프로필 상태에 반영(업로드 전)
  void setLocalDocument({
    required String type, // 'resume' | 'cover_letter'
    required String localPath,
    required String filename,
  }) {
    final p = _myStudentProfile;
    if (p == null) return;

    final docs = [...p.documents];
    final idx = docs.indexWhere((d) => d.type == type);

    final newDoc = StudentDocument(
      type: type,
      localPath: localPath,
      filename: filename,
      url: null,
    );

    if (idx >= 0) {
      docs[idx] = newDoc;
    } else {
      docs.add(newDoc);
    }

    _myStudentProfile = p.copyWith(documents: docs);

    // ✅ 캐시에도 반영
    _cacheStudent(_myStudentProfile!);

    notifyListeners();
  }

  void clear() {
    _myStudentProfile = null;
    notifyListeners();
  }
}
