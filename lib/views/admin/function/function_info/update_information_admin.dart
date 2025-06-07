import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/views/admin/function/function_info/edit_user_info_bottom_sheet.dart';
import 'package:rock_classifier/views/admin/function/function_info/update_password_admin/update_password_admin.dart';
import 'package:rock_classifier/data/models/user_models.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';

// =======================================================================
//                           MÀN HÌNH CHÍNH
// =======================================================================
class UpdateInformationAdmin extends StatelessWidget {
  const UpdateInformationAdmin({super.key});

  // --- LOGIC XỬ LÝ HÌNH ẢNH ---
  Future<void> _pickImage(BuildContext context, AuthViewModel authViewModel) async {
    final source = await _selectImageSource(context);
    if (source == null) return;

    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (pickedFile == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    bool success = await authViewModel.uploadAvatar(File(pickedFile.path));

    if (context.mounted) {
      if (success) {
        // THAY ĐỔI: Dùng key dịch
        messenger.showSnackBar(SnackBar(
          content: Text("settings.edit_profile.avatar_update_success".tr()),
          backgroundColor: Colors.green,
        ));
      } else {
        messenger.showSnackBar(SnackBar(
          // THAY ĐỔI: Dùng key dịch và có fallback
          content: Text(authViewModel.errorMessage ?? "settings.edit_profile.avatar_update_failed".tr()),
          backgroundColor: theme.colorScheme.error,
        ));
      }
    }
  }

  // --- UI CHỌN NGUỒN ẢNH ---
  Future<ImageSource?> _selectImageSource(BuildContext context) {
    final theme = Theme.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              // THAY ĐỔI: Dùng key dịch
              child: Text("settings.edit_profile.image_source_title".tr(), style: theme.textTheme.titleMedium),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: theme.colorScheme.primary),
              // THAY ĐỔI: Dùng key dịch
              title: Text('settings.edit_profile.image_source_gallery'.tr()),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: theme.colorScheme.primary),
              // THAY ĐỔI: Dùng key dịch
              title: Text('settings.edit_profile.image_source_camera'.tr()),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isLoading && authViewModel.currentUser == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authViewModel.currentUser;
        if (user == null) {
          // THAY ĐỔI: Dùng key dịch cho cả AppBar và Body
          return Scaffold(
            appBar: AppBar(title: Text("settings.edit_profile.title".tr())),
            body: Center(child: Text('auth.errors.user_not_found'.tr())),
          );
        }

        return Scaffold(
          appBar: AppBar(
            // THAY ĐỔI: Dùng key dịch
            title: Text("settings.edit_profile.title".tr()),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                // THAY ĐỔI: Dùng key dịch
                tooltip: 'settings.edit_profile.edit_tooltip'.tr(),
                onPressed: () => editUserInfoBottomSheet(context, user),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _AvatarSection(user: user, onPickImage: () => _pickImage(context, authViewModel)),
                  const SizedBox(height: 24),
                  _InfoSection(
                    // THAY ĐỔI: Dùng key dịch
                    title: "settings.edit_profile.personal_info_section".tr(),
                    children: [
                      // THAY ĐỔI: Dùng key từ mục admin_home đã có
                      _InfoTile(
                        title: "admin_home.label_username".tr(),
                        value: user.fullName ?? "common.no_data_available".tr(),
                      ),
                      _InfoTile(
                        title: "admin_home.label_address".tr(),
                        value: user.address ?? "common.no_data_available".tr(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _InfoSection(
                    // THAY ĐỔI: Dùng key dịch
                    title: "settings.edit_profile.account_info_section".tr(),
                    children: [
                      // THAY ĐỔI: Dùng key từ mục admin_home đã có
                      _InfoTile(title: "admin_home.label_email".tr(), value: user.email),
                      // Tách _InfoTile ra để có thể thêm onTap
                      ListTile(
                        // THAY ĐỔI: Dùng key dịch
                        title: Text("settings.edit_profile.change_password".tr(), style: Theme.of(context).textTheme.bodyLarge),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdatePasswordAdmin())),
                      ),
                    ],
                  ),
                ],
              ),
              if (authViewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        // THAY ĐỔI: Dùng key dịch
                        Text("common.loading".tr(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// =======================================================================
//                           CÁC WIDGET CON
// =======================================================================

class _AvatarSection extends StatelessWidget {
  final UserModels user;
  final VoidCallback onPickImage;
  const _AvatarSection({required this.user, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onPickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.surfaceVariant,
              backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null ? Icon(Icons.person, size: 50, color: theme.colorScheme.secondary) : null,
            ),
          ),
          const SizedBox(height: 12),
          // THAY ĐỔI: Dùng key dịch
          Text(user.fullName ?? "settings.edit_profile.unnamed".tr(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(user.email, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(title, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
        child: Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
