import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/views/users/home_page_user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    bool success = await authViewModel.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _confirmPasswordController.text.trim(),
      fullName: _fullNameController.text.trim(),
    );

    if (success) {
      messenger.showSnackBar(
        SnackBar(
            // THAY ĐỔI: Sử dụng key từ file JSON
            content: Text('auth.register.register_success'.tr()),
            backgroundColor: Colors.green),
      );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePageUser()),
        (route) => false,
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          // THAY ĐỔI: Sử dụng key từ file JSON và có fallback
          content: Text(authViewModel.errorMessage ?? 'auth.errors.register_failed_generic'.tr()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        // THAY ĐỔI: Sử dụng key 'auth.register.title'
        title: Text('auth.register.title'.tr()),
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
                    const SizedBox(height: 32),
                    _buildEmailField(theme),
                    const SizedBox(height: 20),
                    _buildFullNameField(theme),
                    const SizedBox(height: 20),
                    _buildPasswordField(theme),
                    const SizedBox(height: 20),
                    _buildConfirmPasswordField(theme),
                    const SizedBox(height: 32),
                    _buildRegisterButton(authViewModel.isLoading),
                    const SizedBox(height: 24),
                    _buildLoginLink(theme),
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
                    // THAY ĐỔI: Sử dụng key 'common.loading'
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
      // THAY ĐỔI: Sử dụng key 'auth.register.title'
      'auth.register.title'.tr(),
      textAlign: TextAlign.center,
      style: theme.textTheme.displaySmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        // THAY ĐỔI: Sử dụng key 'auth.register.email_label'
        labelText: 'auth.register.email_label'.tr(),
        prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.secondary),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty || !value.contains('@')) {
          // THAY ĐỔI: Sử dụng key 'auth.errors.email_invalid'
          return 'auth.errors.email_invalid'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildFullNameField(ThemeData theme) {
    return TextFormField(
      controller: _fullNameController,
      decoration: InputDecoration(
        // THAY ĐỔI: Sử dụng key 'auth.register.fullname_label'
        labelText: 'auth.register.fullname_label'.tr(),
        prefixIcon: Icon(Icons.person_outline, color: theme.colorScheme.secondary),
      ),
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        // THAY ĐỔI: Sử dụng key 'auth.register.password_label'
        labelText: 'auth.register.password_label'.tr(),
        prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.secondary),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: theme.colorScheme.primary),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.length < 6) {
          // THAY ĐỔI: Sử dụng key 'auth.errors.password_length'
          return 'auth.errors.password_length'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(ThemeData theme) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        // THAY ĐỔI: Sử dụng key 'auth.register.confirm_password_label'
        labelText: 'auth.register.confirm_password_label'.tr(),
        prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.secondary),
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: theme.colorScheme.primary),
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
      ),
      validator: (value) {
        if (value != _passwordController.text) {
          // THAY ĐỔI: Sử dụng key 'auth.errors.password_mismatch'
          return 'auth.errors.password_mismatch'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleRegister,
      // THAY ĐỔI: Sử dụng key 'auth.register.register_button'
      child: Text('auth.register.register_button'.tr()),
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      // THAY ĐỔI: Sử dụng key 'auth.register.login_prompt'
      Text('auth.register.login_prompt'.tr(), style: theme.textTheme.bodyMedium),
      TextButton(
        onPressed: () => Navigator.pop(context),
        // THAY ĐỔI: Sử dụng key 'auth.register.login_link'
        child: Text('auth.register.login_link'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
      )
    ]);
  }
}
