import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/views/admin/function/function_info/update_information_admin.dart';
import 'package:rock_classifier/views/admin/function/function_interface/interface_language/language_screen.dart';
import 'package:rock_classifier/data/models/user_models.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/views/auth/login_page.dart';

class InformationPageAdmin extends StatelessWidget {
  const InformationPageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy theme một lần ở đây để sử dụng
    final theme = Theme.of(context);

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (authViewModel.currentUser == null) {
          // THAY ĐỔI: Sử dụng key dịch chính thức
          return Center(child: Text('auth.errors.user_not_found'.tr()));
        }

        final user = authViewModel.currentUser!;
        return Scaffold(
          // THAY ĐỔI: Dùng màu nền từ theme
          backgroundColor: theme.colorScheme.background,
          // THAY ĐỔI: AppBar tự động nhận style từ theme
          appBar: AppBar(
            automaticallyImplyLeading: false,
            // THAY ĐỔI: Dùng key dịch chính thức
            title: Text("settings.title".tr()),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                UserInfoSection(user: user),
                const SizedBox(height: 24),
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

// --- CÁC WIDGET CON ĐÃ ĐƯỢC REFACTOR ---

class SettingsLabel extends StatelessWidget {
  final String value;
  const SettingsLabel({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // THAY ĐỔI: Tương tự LabelText ở trang Home
    return Row(
      children: [
        Icon(
          Icons.settings_outlined,
          color: theme.colorScheme.primary,
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(
          value,
          // Dùng style headlineMedium từ theme
          style: theme.textTheme.headlineMedium,
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
    final theme = Theme.of(context);
    final avatarUrl = user.avatar;

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          // THAY ĐỔI: Dùng màu từ theme
          backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Icon(
                  Icons.person,
                  size: 50,
                  // THAY ĐỔI: Dùng màu từ theme
                  color: theme.colorScheme.secondary,
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          // THAY ĐỔI: Dùng key dịch chính thức
          user.fullName ?? "common.no_data_available".tr(),
          // THAY ĐỔI: Dùng style từ theme
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          // THAY ĐỔI: Dùng style từ theme
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
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
        icon: const Icon(Icons.logout), // màu tự động là onPrimary (trắng)
        label: Text("common.logout".tr()), // Dùng key dịch
        // THAY ĐỔI: Style nút Đăng xuất
        style: ElevatedButton.styleFrom(
          // Sử dụng errorColor từ theme để có sự nhất quán
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError, // Thường là màu trắng
        ).copyWith(
          // Tái sử dụng style của ElevatedButton mặc định nhưng ghi đè màu
          textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.labelLarge),
        ),
        onPressed: () async {
          await authViewModel.signOut();
          // Đảm bảo navigator có thể truy cập context
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // THAY ĐỔI: Dùng widget Label và key dịch
        SettingsLabel(value: "settings.main_section_title".tr()),
        const SizedBox(height: 12),
        // THAY ĐỔI: Dùng Card thay cho Container
        Card(
          clipBehavior: Clip.antiAlias,
          // Bỏ padding trong Card, đưa vào trong các MenuItem
          child: Column(
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.edit_outlined,
                // THAY ĐỔI: Dùng key dịch
                text: "settings.edit_info".tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UpdateInformationAdmin()),
                  );
                },
              ),
              const Divider(indent: 16, endIndent: 16, height: 1),
              _buildMenuItem(
                context: context,
                icon: Icons.language_outlined,
                // THAY ĐỔI: Dùng key dịch
                text: "settings.language".tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LanguageScreen()),
                  );
                },
              ),
              const Divider(indent: 16, endIndent: 16, height: 1),
              _buildMenuItem(
                context: context,
                icon: Icons.palette_outlined,
                // THAY ĐỔI: Dùng key dịch
                text: "settings.theme".tr(),
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

  // THAY ĐỔI: Widget con để xây dựng các mục cài đặt
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                // THAY ĐỔI: Dùng style từ theme
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
