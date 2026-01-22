import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/common/widgets.dart';
import 'profile_model.dart';

class ApplicantProfileViewPage extends StatelessWidget {
  final StudentProfile profile;

  const ApplicantProfileViewPage({
    super.key,
    required this.profile,
  });

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    if (uri.scheme != 'http' && uri.scheme != 'https') return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _linkRow(BuildContext context, String label, String? url) {
    if (url == null || url.trim().isEmpty) return Text('$label: -');
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

  StudentDocument? _doc(String type) {
    for (final d in profile.documents) {
      if (d.type == type) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final resume = _doc('resume');
    final cover = _doc('cover_letter');

    return AppScaffold(
      title: 'Applicant Profile',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Student', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Student ID: ${profile.userId}'),
                  Text('Name: ${profile.name.isEmpty ? "-" : profile.name}'),
                  Text('School: ${profile.school ?? "-"}'),
                  Text('Major: ${profile.major ?? "-"}'),
                  Text('Available: ${profile.availableTime ?? "-"}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Skills', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(profile.skills.isEmpty ? '-' : profile.skills.join(', ')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Links', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  _linkRow(context, 'GitHub', profile.githubUrl),
                  _linkRow(context, 'Portfolio', profile.portfolioUrl),
                  _linkRow(context, 'LinkedIn', profile.linkedinUrl),
                  _linkRow(context, 'Notion', profile.notionUrl),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Documents', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Resume: ${resume?.filename ?? "-"}'),
                  Text('Cover Letter: ${cover?.filename ?? "-"}'),
                  const SizedBox(height: 6),
                  const Text(
                    'Note: In this stage, documents are only selected on the device (not uploaded).',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
