import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);

    bool success = await authViewModel.sendPasswordResetEmail(_emailController.text.trim());

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('auth.forgot_password.reset_link_sent_success'.tr()),
          backgroundColor: Colors.green,
        ),
      );
      // Quay lại trang đăng nhập sau khi gửi thành công
      navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'auth.forgot_password.reset_failed_generic'.tr()),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('auth.forgot_password.title'.tr()),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.primary,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitle(theme),
                    const SizedBox(height: 16),
                    _buildInstruction(theme),
                    const SizedBox(height: 32),
                    _buildEmailField(theme),
                    const SizedBox(height: 32),
                    _buildSendButton(authViewModel.isLoading),
                  ],
                ),
              ),
            ),
          ),
          if (authViewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text('common.loading'.tr(), style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      'auth.forgot_password.title'.tr(),
      textAlign: TextAlign.center,
      style: theme.textTheme.displaySmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInstruction(ThemeData theme) {
    return Text(
      'auth.forgot_password.instruction'.tr(),
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'auth.login.email_hint'.tr(), // Tái sử dụng hint từ trang login
        prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.secondary),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty || !value.contains('@')) {
          return 'auth.errors.email_invalid'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildSendButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleSendResetLink,
      child: Text('auth.forgot_password.send_button'.tr()),
    );
  }
}
