import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/common/widgets.dart';
import '../auth/auth_model.dart';
import 'profile_model.dart';

class UserProfilePage extends StatelessWidget {
  final UserOut user;
  final StudentProfile? studentProfile;

  const UserProfilePage({
    super.key,
    required this.user,
    this.studentProfile,
  });

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    if (uri.scheme != 'http' && uri.scheme != 'https') return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      // 실패 시 조용히 무시해도 되고, 원하면 snack 처리 가능
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to open link.')));
    }
  }

  StudentDocument? _findDoc(StudentProfile? p, String type) {
    if (p == null) return null;
    for (final d in p.documents) {
      if (d.type == type) return d;
    }
    return null;
  }

  Widget _linkRow(BuildContext context, String label, String? url) {
    if (url == null || url.trim().isEmpty) {
      return Text('$label: -');
    }
    return Row(
      children: [
        Expanded(child: Text('$label: $url', overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => _openUrl(context, url),
          child: const Text('Open'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = studentProfile;
    final resume = _findDoc(p, 'resume');
    final cover = _findDoc(p, 'cover_letter');

    return AppScaffold(
      title: 'User Profile',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ID: ${user.id}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Role: ${user.role.name}'),
                  Text('Email: ${user.email ?? "-"}'),
                  Text('Phone: ${user.phone ?? "-"}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (user.role == UserRole.STUDENT) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: p == null
                    ? const Text('Student profile not loaded.')
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Student Profile',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Name: ${p.name}'),
                    Text('School: ${p.school ?? "-"}'),
                    Text('Major: ${p.major ?? "-"}'),
                    Text('Available: ${p.availableTime ?? "-"}'),
                    const SizedBox(height: 8),
                    const Text('Skills',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(p.skills.isEmpty ? '-' : p.skills.join(', ')),

                    const SizedBox(height: 16),
                    const Text('Links',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    _linkRow(context, 'GitHub', p.githubUrl),
                    _linkRow(context, 'Portfolio', p.portfolioUrl),
                    _linkRow(context, 'LinkedIn', p.linkedinUrl),
                    _linkRow(context, 'Notion', p.notionUrl),

                    const SizedBox(height: 16),
                    const Text('Documents',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Resume: ${resume?.filename ?? "-"}'),
                    Text('Cover Letter: ${cover?.filename ?? "-"}'),
                    const SizedBox(height: 6),
                    const Text(
                      'Note: In this stage, documents are only selected on device (not uploaded).',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
