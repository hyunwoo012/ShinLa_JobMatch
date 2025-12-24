import 'package:flutter/material.dart';

import '../../core/common/widgets.dart';
import '../../main.dart';
import 'auth_model.dart';
import 'login_page.dart';
import 'signup_page.dart';

class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage> {
  UserRole _role = UserRole.worker;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Role Select',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const LabeledBox(
            label: 'Note',
            child: Text('Please Select Your Role.'),
          ),
          const SizedBox(height: 12),
          LabeledBox(
            label: 'Role',
            child: Column(
              children: [
                RadioListTile<UserRole>(
                  title: const Text('Employee'),
                  value: UserRole.worker,
                  groupValue: _role,
                  onChanged: (v) => setState(() => _role = v!),
                ),
                RadioListTile<UserRole>(
                  title: const Text('Employer'),
                  value: UserRole.employer,
                  groupValue: _role,
                  onChanged: (v) => setState(() => _role = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: 'LogIn',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginPage(role: _role)),
              );
            },
          ),
          const SizedBox(height: 8),
          OutlineButton(
            text: 'SignUp',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SignupPage(role: _role)),
              );
            },
          ),
        ],
      ),
    );
  }
}
