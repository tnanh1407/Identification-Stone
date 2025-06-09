import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/views/admin/main_page_admin.dart';
import 'package:rock_classifier/views/auth/forgotpassworl_screen.dart';
import 'package:rock_classifier/views/auth/register_page.dart';
import 'package:rock_classifier/views/users/main_page_user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    bool success = await authViewModel.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      if (authViewModel.isAdmin() || authViewModel.isSuperUser()) {
        navigator.pushReplacement(MaterialPageRoute(builder: (context) => const MainPageAdmin()));
      } else if (authViewModel.isUser()) {
        navigator.pushReplacement(MaterialPageRoute(builder: (context) => const MainPageUser()));
      }
    } else {
      messenger.showSnackBar(
        SnackBar(
          // THAY ĐỔI: Thêm fallback key được dịch
          content: Text(authViewModel.errorMessage ?? 'auth.errors.login_failed_generic'.tr()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitle(theme),
                    const SizedBox(height: 40),
                    _buildEmailField(theme),
                    const SizedBox(height: 20),
                    _buildPasswordField(theme),
                    _buildForgotPasswordButton(theme),
                    const SizedBox(height: 20),
                    _buildLoginButton(authViewModel.isLoading),
                    const SizedBox(height: 20),
                    _buildDivider(theme),
                    const SizedBox(height: 20),
                    _buildSocialLoginButtons(),
                    const SizedBox(height: 20),
                    _buildRegisterLink(theme),
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
      // THAY ĐỔI: Sử dụng key 'auth.login.title'
      'auth.login.title'.tr(),
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
        // THAY ĐỔI: Sử dụng key 'auth.login.email_hint'
        hintText: 'auth.login.email_hint'.tr(),
        prefixIcon: Icon(Icons.email, color: theme.colorScheme.secondary),
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

  Widget _buildPasswordField(ThemeData theme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        // THAY ĐỔI: Sử dụng key 'auth.login.password_hint'
        hintText: 'auth.login.password_hint'.tr(),
        prefixIcon: Icon(Icons.lock, color: theme.colorScheme.secondary),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: theme.colorScheme.primary),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          // THAY ĐỔI: Sử dụng key 'auth.errors.password_required'
          return 'auth.errors.password_required'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordButton(ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        // CẬP NHẬT onPresed
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
          );
        },
        child: Text('auth.login.forgot_password'.tr()),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleLogin,
      // THAY ĐỔI: Sử dụng key 'auth.login.login_button'
      child: Text('auth.login.login_button'.tr()),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        // THAY ĐỔI: Sử dụng key 'auth.login.divider_text'
        child: Text('auth.login.divider_text'.tr(), style: theme.textTheme.bodySmall),
      ),
      const Expanded(child: Divider())
    ]);
  }

  Widget _buildSocialLoginButtons() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
      Icon(Icons.android, size: 40, color: Colors.green),
      SizedBox(width: 16),
      Icon(Icons.apple, size: 40, color: Colors.grey),
      SizedBox(width: 16),
      Icon(Icons.facebook, size: 40, color: Colors.blue)
    ]);
  }

  Widget _buildRegisterLink(ThemeData theme) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      // THAY ĐỔI: Sử dụng key 'auth.login.register_prompt'
      Text('auth.login.register_prompt'.tr(), style: theme.textTheme.bodyMedium),
      TextButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
        // THAY ĐỔI: Sử dụng key 'auth.login.register_link'
        child: Text('auth.login.register_link'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
      )
    ]);
  }
}
