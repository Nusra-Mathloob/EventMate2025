import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Information'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              // TODO: Navigate to Privacy Policy or show dialog
              Get.snackbar('Info', 'Privacy Policy coming soon');
            },
          ),
          const Divider(),
          _buildInfoTile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            onTap: () {
              // TODO: Navigate to Terms or show dialog
              Get.snackbar('Info', 'Terms of Service coming soon');
            },
          ),
          const Divider(),
          _buildInfoTile(
            context,
            icon: Icons.info_outline,
            title: 'About Us',
            subtitle: 'Learn more about EventMate',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'EventMate',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 EventMate Inc.',
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'EventMate is your go-to app for discovering and managing events.',
                  ),
                ],
              );
            },
          ),
          const Divider(),
          _buildInfoTile(
            context,
            icon: Icons.android,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: () {},
            showArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: showArrow
          ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }
}
