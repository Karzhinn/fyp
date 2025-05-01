import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/Services/auth.provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? const Center(child: Text("No user logged in"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Email: ${user.email ?? ''}"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await authProvider.signOut();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text('Logout'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _showChangePasswordDialog(context),
                    child: const Text('Change Password'),
                  ),
                ],
              ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter new password',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser!
                    .updatePassword(passwordController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password updated")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
