class JobPost {
  JobPost({
    required this.id,
    required this.title,
    required this.shopName,
    required this.wage,
    required this.content,
    required this.employerId,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String shopName;
  final int wage;
  final String content;
  final String employerId;
  final DateTime createdAt;

  JobPost copyWith({
    String? title,
    String? shopName,
    int? wage,
    String? content,
  }) {
    return JobPost(
      id: id,
      title: title ?? this.title,
      shopName: shopName ?? this.shopName,
      wage: wage ?? this.wage,
      content: content ?? this.content,
      employerId: employerId,
      createdAt: createdAt,
    );
  }
}
