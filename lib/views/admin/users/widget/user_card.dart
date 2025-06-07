import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rock_classifier/data/models/user_models.dart';

class UserCard extends StatelessWidget {
  final UserModels user;
  final VoidCallback? onMorePressed;
  final VoidCallback? onTap;

  const UserCard({super.key, required this.user, this.onMorePressed, this.onTap});

  // --- HÀM HELPER ĐỂ TẠO CHIP VAI TRÒ ---
  Widget _buildRoleChip(BuildContext context) {
    final theme = Theme.of(context);
    String roleText;
    Color chipColor;
    Color textColor;

    // Xác định màu và chữ cho từng vai trò
    switch (user.role) {
      case 'Admin':
        roleText = 'user_management.roles.admin'.tr();
        chipColor = theme.colorScheme.primary.withOpacity(0.15);
        textColor = theme.colorScheme.primary;
        break;
      case 'Super-User':
        roleText = 'user_management.roles.super_user'.tr();
        chipColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange.shade800;
        break;
      default: // User
        roleText = 'user_management.roles.user'.tr();
        chipColor = theme.colorScheme.secondary.withOpacity(0.15);
        textColor = theme.colorScheme.secondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        roleText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // THAY ĐỔI: Dùng widget Card để tự động lấy style từ theme
    return Card(
      // Các thuộc tính như shape, elevation, color đã được định nghĩa trong cardTheme
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      clipBehavior: Clip.antiAlias, // Đảm bảo InkWell không tràn ra ngoài
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // --- AVATAR ---
              Hero(
                tag: 'avatar-${user.uid}',
                child: CircleAvatar(
                  radius: 28,
                  // Dùng màu từ theme cho nền
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                  child: user.avatar == null
                      ? Icon(
                          Icons.person_outline,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 30,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // --- THÔNG TIN CHÍNH (TÊN, EMAIL, VAI TRÒ) ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên người dùng
                    Text(
                      // THAY ĐỔI: Dùng key dịch
                      user.fullName ?? 'common.no_data_available'.tr(),
                      // Dùng style từ theme
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      user.email,
                      // Dùng style từ theme
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // THÊM MỚI: Chip hiển thị vai trò
                    _buildRoleChip(context),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // --- NÚT TÙY CHỌN ---
              if (onMorePressed != null)
                IconButton(
                  icon: Icon(Icons.more_vert, color: theme.colorScheme.secondary),
                  onPressed: onMorePressed,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
