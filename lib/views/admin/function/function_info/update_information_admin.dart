import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/Views/admin/function/function_info/edit_user_info_bottom_sheet.dart';
import 'package:rock_classifier/Views/admin/function/function_info/update_password_admin/update_password_admin.dart';
import 'package:rock_classifier/data/models/user_models.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';

class UpdateInformationAdmin extends StatefulWidget {
  const UpdateInformationAdmin({super.key});

  @override
  State<UpdateInformationAdmin> createState() => _UpdateInformationAdminState();
}

class _UpdateInformationAdminState extends State<UpdateInformationAdmin> {
  // Hàm xử lí hình ảnh (đã chọn phương thức)
  Future<void> _pickImage(UserModels user) async {
    final source = await _selectedImageSource();
    if (source == null) return;

    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final url = await authViewModel.uploadAvatar(File(pickedFile.path));
    Navigator.of(context).pop();
    if (url != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã cập nhật ảnh thành công !"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thêm ảnh không thành công !"),
        ),
      );
    }
  }

  //  Hàm lấy ra lựa chọn
  Future<ImageSource?> _selectedImageSource() async {
    return await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Chọn nguồn ảnh",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Máy ảnh'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F0F0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = authViewModel.currentUser;
        if (user == null) {
          return Center(child: Text('Unable_to_find_user_information'.tr()));
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
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
            title: Text("textEditAdmin9".tr(), style: Theme.of(context).textTheme.titleLarge),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Chỉnh sửa',
                  onPressed: () {
                    editUserInfoBottomSheet(context, user);
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AvatarSection(user: user, onPickImage: _pickImage),
                const SizedBox(height: 16),
                PersonalInfoSection(buildListTile: _buildListTile, user: user),
                const SizedBox(height: 16),
                // Email and Password
                AccountPasswordSection(
                  buildListTile: _buildListTile,
                  user: user,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AvatarSection extends StatelessWidget {
  final UserModels user;
  final Function(UserModels) onPickImage;
  const AvatarSection({super.key, required this.user, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5)],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => onPickImage(user),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
            ),
          ),
          const SizedBox(height: 12),
          Text("textEditAdmin2".tr(), style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class PersonalInfoSection extends StatelessWidget {
  final UserModels user;
  final Widget Function({
    required String title,
    required String value,
  }) buildListTile;

  const PersonalInfoSection({super.key, required this.user, required this.buildListTile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5)],
      ),
      child: Column(
        children: [
          buildListTile(
            title: "textEditAdmin3".tr(),
            value: user.fullName ?? "no_data_available".tr(),
          ),
          buildListTile(
            title: "textEditAdmin4".tr(),
            value: user.address ?? "no_data_available".tr(),
          ),
        ],
      ),
    );
  }
}

class AccountPasswordSection extends StatelessWidget {
  final UserModels user;
  final Widget Function({
    required String title,
    required String value,
  }) buildListTile;

  const AccountPasswordSection({super.key, required this.user, required this.buildListTile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text("textEditAdmin5".tr(), style: Theme.of(context).textTheme.titleMedium),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5)],
          ),
          child: Column(
            children: [
              buildListTile(
                title: "textEditAdmin6".tr(),
                value: user.email,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdatePasswordAdmin(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("textEditAdmin7".tr(), style: Theme.of(context).textTheme.bodyMedium),
                      Text("textEditAdmin8".tr(), style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
