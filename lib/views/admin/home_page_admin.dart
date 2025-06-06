import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/views/admin/news/news_data_management.dart';
import 'package:rock_classifier/views/admin/rocks/rock_list_screen.dart';
import 'package:rock_classifier/views/admin/users/view/user_data_management.dart';

class HomePageAdmin extends StatelessWidget {
  const HomePageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Kiểm tra trạng thái
        if (authViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (authViewModel.currentUser == null) {
          return Center(child: Text("no_data_available".tr()));
        }

        final user = authViewModel.currentUser!;
        return Scaffold(
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
            title: Text("textHomeAdmin1".tr(), style: Theme.of(context).textTheme.titleLarge),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabelText1(value: "textHomeAdmin2".tr()),
                const SizedBox(height: 16),
                UserInfoCard(user: user),
                const SizedBox(height: 28),
                LabelText1(value: 'textHomeAdmin3'.tr()),
                SizedBox(height: 16),
                FunctionButton(
                  title: 'textHomeAdmin6'.tr(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDataManagement(),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                FunctionButton(
                  title: 'textHomeAdmin7'.tr(),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RockListScreen(),
                        ));
                  },
                ),
                SizedBox(height: 16),
                FunctionButton(
                  title: 'textHomeAdmin8'.tr(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDataManagement(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ignore: camel_case_types
class rowInfo extends StatelessWidget {
  final String label;
  final String value;

  const rowInfo({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
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

  const FunctionButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// label Thông tin người dùng
class LabelText1 extends StatelessWidget {
  final String value;
  const LabelText1({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.person,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class UserInfoCard extends StatelessWidget {
  final dynamic user;
  const UserInfoCard({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Avatar nền
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey,
                  child: user.avatar == null
                      ? Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        )
                      : null,
                ),
                // Nếu có avatar, tải ảnh từ mạng
                if (user.avatar != null)
                  ClipOval(
                    child: Image.network(
                      user.avatar!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error, color: Colors.white);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                rowInfo(label: 'textHomeAdmin4'.tr(), value: user.email),
                rowInfo(
                  label: 'textHomeAdmin5'.tr(),
                  value: user.fullName ?? "no_data_available".tr(),
                ),
                rowInfo(label: 'textHomeAdmin10'.tr(), value: user.address ?? 'no_data_available'.tr()),
                rowInfo(
                  label: 'textHomeAdmin11'.tr(),
                  value: user.role ?? 'no_data_available'.tr(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
