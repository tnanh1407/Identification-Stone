import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';

class UpdatePasswordAdmin extends StatefulWidget {
  const UpdatePasswordAdmin({super.key});

  @override
  State<UpdatePasswordAdmin> createState() => _UpdatePasswordAdminState();
}

class _UpdatePasswordAdminState extends State<UpdatePasswordAdmin> {
  final _formKey = GlobalKey<FormState>();
  final _passOldController = TextEditingController();
  final _passNewController = TextEditingController();
  final _passConfirmController = TextEditingController();

  @override
  void dispose() {
    _passOldController.dispose();
    _passNewController.dispose();
    _passConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final oldPass = _passOldController.text.trim();
    final newPass = _passNewController.text.trim();

    bool success = await authViewModel.updatePassword(oldPass, newPass);

    if (context.mounted) {
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            // THAY ĐỔI: Dùng key dịch
            content: Text('settings.change_password.update_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      } else {
        messenger.showSnackBar(
          SnackBar(
            // THAY ĐỔI: Dùng key dịch và có fallback
            content: Text(authViewModel.errorMessage ?? 'settings.change_password.update_failed_generic'.tr()),
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

    return Scaffold(
      appBar: AppBar(
        // THAY ĐỔI: Dùng key dịch
        title: Text("settings.change_password.title".tr()),
      ),
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPasswordField(
                      controller: _passOldController,
                      // THAY ĐỔI: Dùng key dịch
                      labelText: "settings.change_password.old_password_label".tr(),
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _passNewController,
                      // THAY ĐỔI: Dùng key dịch
                      labelText: "settings.change_password.new_password_label".tr(),
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _passConfirmController,
                      // THAY ĐỔI: Dùng key dịch
                      labelText: "settings.change_password.confirm_new_password_label".tr(),
                      validator: (value) {
                        if (value != _passNewController.text) {
                          // THAY ĐỔI: Dùng key dịch
                          return 'settings.change_password.password_mismatch_error'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: authViewModel.isLoading ? null : _handleUpdatePassword,
                      // THAY ĐỔI: Dùng key dịch
                      child: Text("settings.change_password.save_button".tr()),
                    ),
                  ],
                ),
              ),
            ),
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
                  Text("common.loading".tr(), style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
                ],
              )),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
  }) {
    return _PasswordTextFieldInternal(
      controller: controller,
      labelText: labelText,
      validator: validator,
    );
  }
}

class _PasswordTextFieldInternal extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;

  const _PasswordTextFieldInternal({
    required this.controller,
    required this.labelText,
    this.validator,
  });

  @override
  State<_PasswordTextFieldInternal> createState() => _PasswordTextFieldInternalState();
}

class _PasswordTextFieldInternalState extends State<_PasswordTextFieldInternal> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          // THAY ĐỔI: Dùng key dịch
          return 'settings.change_password.password_required_error'.tr();
        }
        if (value.length < 6) {
          // THAY ĐỔI: Dùng key dịch
          return 'settings.change_password.password_length_error'.tr();
        }
        if (widget.validator != null) {
          return widget.validator!(value);
        }
        return null;
      },
    );
  }
}
