import 'package:flutter/material.dart';

import '../../core/common/widgets.dart';
import '../../main.dart';
import '../auth/auth_model.dart';
import 'applicant_profile_view_page.dart';

class ApplicantsPage extends StatelessWidget {
  const ApplicantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final me = scope.auth.me;

    if (me == null) {
      return const AppScaffold(
        title: 'Applicants',
        body: Center(child: Text('Not signed in.')),
      );
    }

    if (me.role != UserRole.COMPANY) {
      return const AppScaffold(
        title: 'Applicants',
        body: Center(child: Text('Only COMPANY can view applicants.')),
      );
    }

    final applicants = scope.profile.cachedStudentProfiles;

    return AppScaffold(
      title: 'Applicants',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Applicants (Demo)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Current stage: This list is based on in-app cached student profiles.\n'
                        'After server API is ready, replace this with real applicants from the backend.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (applicants.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No applicants cached yet.\n\n'
                      'Tip: Log in as a STUDENT, load/save the student profile once,\n'
                      'then come back as COMPANY to see it here (demo).',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: applicants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final p = applicants[i];
                  return Card(
                    child: ListTile(
                      title: Text(
                        p.name.isEmpty ? '(No name)' : p.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Student ID: ${p.userId}\n'
                            'School: ${p.school ?? "-"} | Major: ${p.major ?? "-"}\n'
                            'Skills: ${p.skills.isEmpty ? "-" : p.skills.join(", ")}',
                      ),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ApplicantProfileViewPage(profile: p),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
