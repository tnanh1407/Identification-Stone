import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/user_models.dart'; // Import model để ép kiểu tường minh
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/views/admin/news/news_data_management.dart';
import 'package:rock_classifier/views/admin/rocks/rock_list_screen.dart';
import 'package:rock_classifier/views/admin/users/view/user_data_management.dart';

class HomePageAdmin extends StatelessWidget {
  const HomePageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    // THAY ĐỔI: Lấy theme một lần ở đây để sử dụng cho toàn bộ trang
    final theme = Theme.of(context);

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (authViewModel.currentUser == null) {
          // THAY ĐỔI: Sử dụng key chính thức
          return Center(child: Text("common.no_data_available".tr()));
        }

        final user = authViewModel.currentUser!;
        return Scaffold(
          // THAY ĐỔI: AppBar tự động nhận style từ appBarTheme.
          // Không cần khai báo backgroundColor, flexibleSpace, elevation nữa.
          appBar: AppBar(
            automaticallyImplyLeading: false,
            // THAY ĐỔI: Sử dụng key 'admin_home.title'
            title: Text("admin_home.title".tr()),
          ),
          // THAY ĐỔI: Sử dụng màu nền chung của theme
          backgroundColor: theme.colorScheme.background,
          body: SingleChildScrollView(
            // Thêm SingleChildScrollView để tránh tràn màn hình
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // THAY ĐỔI: Dùng key 'admin_home.user_info_card_title'
                LabelText(value: "admin_home.user_info_card_title".tr()),
                const SizedBox(height: 16),
                UserInfoCard(user: user),
                const SizedBox(height: 28),
                // THAY ĐỔI: Dùng key 'admin_home.functions_card_title'
                LabelText(value: 'admin_home.functions_card_title'.tr()),
                const SizedBox(height: 16),
                FunctionButton(
                  // THAY ĐỔI: Dùng key 'admin_home.manage_accounts'
                  title: 'admin_home.manage_accounts'.tr(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserDataManagement()),
                  ),
                ),
                const SizedBox(height: 16),
                FunctionButton(
                  // THAY ĐỔI: Dùng key 'admin_home.manage_data'
                  title: 'admin_home.manage_data'.tr(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RockListScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                FunctionButton(
                  // THAY ĐỔI: Dùng key 'admin_home.manage_blogs'
                  title: 'admin_home.manage_blogs'.tr(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewsDataManagement()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- CÁC WIDGET CON ĐÃ ĐƯỢC "THEME HÓA" ---

class RowInfo extends StatelessWidget {
  final String label;
  final String value;

  const RowInfo({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            // THAY ĐỔI: Dùng bodyMedium cho label, phù hợp hơn
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              // THAY ĐỔI: Dùng bodyMedium màu nhạt hơn cho value
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class FunctionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const FunctionButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // THAY ĐỔI: Dùng Card để tự động lấy style từ cardTheme
    return Card(
      // Để hiệu ứng InkWell không bị tràn ra ngoài Card, chúng ta cần set clipBehavior.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                // Lấy style titleMedium từ theme
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Icon(
                Icons.arrow_forward_ios,
                // Lấy màu phụ từ theme
                color: theme.colorScheme.secondary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LabelText extends StatelessWidget {
  final String value;
  const LabelText({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // THAY ĐỔI: Đã được theme hóa hoàn toàn
    return Row(
      children: [
        Icon(
          Icons.label_important_outline,
          // Lấy màu chính từ theme
          color: theme.colorScheme.primary,
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(
          value,
          // Dùng style headlineMedium đã định nghĩa trong theme
          // (fontSize: 18, fontWeight: FontWeight.bold)
          style: theme.textTheme.headlineMedium,
        ),
      ],
    );
  }
}

class UserInfoCard extends StatelessWidget {
  // THAY ĐỔI: Ép kiểu tường minh để code an toàn hơn
  final UserModels user;
  const UserInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // THAY ĐỔI: Dùng Card để tự động lấy style từ cardTheme
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              // THAY ĐỔI: Dùng màu phụ từ theme làm nền
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
              radius: 36,
              // THAY ĐỔI: Dùng ảnh từ mạng hoặc icon mặc định
              backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null
                  ? Icon(
                      Icons.person,
                      // Lấy màu trên nền phụ từ theme
                      color: theme.colorScheme.secondary,
                      size: 40,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // THAY ĐỔI: Sử dụng widget RowInfo và các key dịch chính thức
                  RowInfo(label: 'admin_home.label_email'.tr(), value: user.email),
                  RowInfo(
                    label: 'admin_home.label_username'.tr(),
                    value: user.fullName ?? "common.no_data_available".tr(),
                  ),
                  RowInfo(
                    label: 'admin_home.label_address'.tr(),
                    value: user.address ?? 'common.no_data_available'.tr(),
                  ),
                  RowInfo(
                    label: 'admin_home.label_role'.tr(),
                    value: user.role,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
