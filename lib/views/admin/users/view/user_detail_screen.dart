// lib/views/admin/users/view/user_detail_screen.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/user_models.dart';
import 'package:rock_classifier/view_models/user_list_view_model.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;
  final VoidCallback onEditPressed;
  final Future<bool> Function() onDeletePressed;

  const UserDetailScreen({
    super.key,
    required this.userId,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<UserListViewModel>(
      builder: (context, viewModel, child) {
        final user = viewModel.users.firstWhere(
          (u) => u.uid == userId,
          orElse: () => UserModels.empty,
        );

        if (user.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('auth.errors.user_not_found'.tr())),
          );
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: AppBar(
            title: Text('user_management.detail_page.title'.tr()),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAvatarSection(context, user),
              const SizedBox(height: 24),
              _buildSectionTitle(context, icon: Icons.person_outline, titleKey: 'user_management.detail_page.info_section_title'),
              _buildInfoCard(context, user),
              const SizedBox(height: 24),
              _buildSectionTitle(context, icon: Icons.settings_outlined, titleKey: 'user_management.detail_page.actions_section_title'),
              _buildActions(context), // SỬA: Không cần truyền user nữa
            ],
          ),
        );
      },
    );
  }

  // ... (các hàm _build... khác giữ nguyên)

  Widget _buildAvatarSection(BuildContext context, UserModels user) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Hero(
              tag: 'avatar-${user.uid}',
              child: CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.surfaceVariant,
                backgroundImage: user.avatar != null && user.avatar!.isNotEmpty ? NetworkImage(user.avatar!) : null,
                child: user.avatar == null || user.avatar!.isEmpty ? Icon(Icons.person, size: 70, color: theme.colorScheme.onSurfaceVariant) : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName ?? 'common.no_data_available'.tr(),
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, UserModels user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _InfoRow(labelKey: 'admin_home.label_username', value: user.fullName ?? 'common.no_data_available'.tr()),
            _InfoRow(labelKey: 'admin_home.label_email', value: user.email),
            _InfoRow(labelKey: 'admin_home.label_address', value: user.address ?? 'common.no_data_available'.tr()),
            _InfoRow(labelKey: 'admin_home.label_role', value: user.role),
            _InfoRow(
              labelKey: 'user_management.detail_page.created_at_label',
              value: DateFormat('dd/MM/yyyy – HH:mm').format(user.createdAt),
            ),
            _InfoRow(labelKey: 'user_management.detail_page.favorite_rocks_label', value: '0'),
            _InfoRow(labelKey: 'user_management.detail_page.collections_count_label', value: '0', hasDivider: false),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, {required IconData icon, required String titleKey}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.secondary, size: 20),
          const SizedBox(width: 8),
          Text(
            titleKey.tr(),
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Nút chỉnh sửa
        ElevatedButton.icon(
          icon: const Icon(Icons.edit_outlined),
          label: Text('user_management.detail_page.edit_user_button'.tr()),
          onPressed: onEditPressed, // Gọi callback
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete_outline),
          label: Text('user_management.detail_page.delete_user_button'.tr()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () async {
            // Chờ kết quả từ hàm onDeletePressed
            final bool success = await onDeletePressed();

            // Nếu xóa thành công và widget vẫn còn trên cây (mounted),
            // thì pop màn hình này đ
            if (success && context.mounted) {
              Navigator.of(context).pop();
            }
          }, // Gọi callback
        ),
      ],
    );
  }
}

// Widget con để hiển thị một dòng thông tin
class _InfoRow extends StatelessWidget {
  final String labelKey;
  final String value;
  final bool hasDivider;

  const _InfoRow({required this.labelKey, required this.value, this.hasDivider = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labelKey.tr(),
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (hasDivider) const Divider(height: 1),
      ],
    );
  }
}
