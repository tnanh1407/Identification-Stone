import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/Views/admin/function/function_info/update_information_admin.dart';
import 'package:rock_classifier/Views/admin/function/function_interface/interface_language/language_screen.dart';
import 'package:rock_classifier/data/models/user_models.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/views/auth/login_page.dart';

class InformationPageAdmin extends StatelessWidget {
  const InformationPageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Kiểm tra trạng thái
        if (authViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (authViewModel.currentUser == null) {
          return const Center(child: Text('Không tìm thấy thông tin người dùng'));
        }

        final user = authViewModel.currentUser!;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: Color(0xFFF7F7F7),
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Text("textInfoAdmin1".tr(), style: Theme.of(context).textTheme.titleLarge),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                UserInfoSection(user: user),
                const SizedBox(height: 26),
                SettingsSection(),
                const SizedBox(height: 24),
                LogoutButton(authViewModel: authViewModel),
              ],
            ),
          ),
        );
      },
    );
  }
}

// TextLabel
class Textlabel extends StatelessWidget {
  final String value;
  const Textlabel({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.settings,
          color: Colors.black,
        ),
        const SizedBox(width: 4),
        Text(
          "textInfoAdmin2".tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class UserInfoSection extends StatelessWidget {
  final UserModels user;
  const UserInfoSection({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatar; // lấy ra avatar
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.grey,
                )
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          user.fullName ?? "no_data_available".tr(),
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          user.email,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}

class LogoutButton extends StatelessWidget {
  final AuthViewModel authViewModel;
  const LogoutButton({super.key, required this.authViewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          "textInfoAdmin6".tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Colors.redAccent.withOpacity(0.4),
        ),
        onPressed: () async {
          await authViewModel.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        },
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F0F0),
      indent: 16,
      endIndent: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Textlabel(value: "textInfoAdmin2".tr()),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.edit,
                text: "textInfoAdmin3".tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdateInformationAdmin(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.language,
                text: "textInfoAdmin4".tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LanguageScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.wb_sunny,
                text: "textInfoAdmin5".tr(),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
