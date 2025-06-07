import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/user_models.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';

// Hàm helper để gọi BottomSheet
void editUserInfoBottomSheet(BuildContext context, UserModels user) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: Theme.of(context).bottomSheetTheme.shape,
    backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
    builder: (_) => EditUserInfoForm(user: user),
  );
}

// --- WIDGET CHÍNH: MỘT STATEFULWIDGET ĐỘC LẬP ---
class EditUserInfoForm extends StatefulWidget {
  final UserModels user;

  const EditUserInfoForm({super.key, required this.user});

  @override
  State<EditUserInfoForm> createState() => _EditUserInfoFormState();
}

class _EditUserInfoFormState extends State<EditUserInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- LOGIC XỬ LÝ ---
  Future<void> _handleUpdateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final updatedUser = widget.user.copyWith(
      fullName: _fullNameController.text.trim(),
      address: _addressController.text.trim(),
    );

    bool success = await authViewModel.updateUser(updatedUser);

    if (context.mounted) {
      if (success) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            // THAY ĐỔI: Dùng key dịch
            content: Text('settings.edit_info_dialog.update_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            // THAY ĐỔI: Dùng key dịch và có fallback
            content: Text(authViewModel.errorMessage ?? 'settings.edit_info_dialog.update_failed'.tr()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch, // Căn chỉnh nút cho đẹp
          children: [
            Center(
              // Đặt thanh kéo ra giữa
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // THAY ĐỔI: Dùng key dịch
            Text(
              'settings.edit_info_dialog.title'.tr(),
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _fullNameController,
              // THAY ĐỔI: Dùng key dịch
              decoration: InputDecoration(labelText: 'settings.edit_info_dialog.fullname_label'.tr()),
              // THAY ĐỔI: Dùng key dịch
              validator: (value) => value == null || value.isEmpty ? 'settings.edit_info_dialog.fullname_required_error'.tr() : null,
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _addressController,
              // THAY ĐỔI: Dùng key dịch
              decoration: InputDecoration(labelText: 'settings.edit_info_dialog.address_label'.tr()),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: authViewModel.isLoading ? null : _handleUpdateUser,
              icon: authViewModel.isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
              // THAY ĐỔI: Dùng key dịch
              label: authViewModel.isLoading
                  ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  : Text('settings.edit_info_dialog.save_button'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
