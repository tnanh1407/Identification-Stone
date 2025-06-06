import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/views/admin/main_page_admin.dart';
import 'package:rock_classifier/views/auth/register_page.dart';
import 'package:rock_classifier/views/users/home_page_user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _iconLoading = true;

  void handleLogin(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    bool success = await authViewModel.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (success) {
      if (authViewModel.isAdmin() || authViewModel.isSuperUser()) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainPageAdmin()));
      } else if (authViewModel.isUser()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePageUser()),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authViewModel.errorMessage ?? "Đăng nhập thất bại")));
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _customInputDecoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF3E5F5),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[700]),
      prefixIcon: Icon(icon, color: Colors.black),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget titleText(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF6A1B9A),
      ),
    );
  }

  Widget inputEmail(String hint) {
    return TextFormField(
      controller: _emailController,
      decoration: _customInputDecoration(hint, Icons.email),
      style: const TextStyle(color: Colors.black87),
    );
  }

  Widget inputPassword(String hint) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _iconLoading,
      decoration: _customInputDecoration(
        hint,
        Icons.lock,
        suffix: IconButton(
          icon: Icon(
            _iconLoading ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF6A1B9A),
          ),
          onPressed: () {
            setState(() {
              _iconLoading = !_iconLoading;
            });
          },
        ),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  Widget labelForgetPassword(String label) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          label,
          style: GoogleFonts.roboto(
            color: const Color(0xFF6A1B9A),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget buttonLogin(String label, bool isLoading) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6A1B9A),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      onPressed: isLoading ? null : () => handleLogin(context),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget labelDivider(String label) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            label,
            style: GoogleFonts.roboto(color: Colors.grey[600], fontSize: 16),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget optionalLoginOther() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.android, size: 40, color: Colors.green),
        SizedBox(width: 16),
        Icon(Icons.apple, size: 40, color: Colors.grey),
        SizedBox(width: 16),
        Icon(Icons.facebook, size: 40, color: Colors.blue),
      ],
    );
  }

  Widget labelText2(String title1, String title2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title1,
          style: GoogleFonts.roboto(fontSize: 16),
        ),
        TextButton(
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const RegisterPage()),
            // );
          },
          child: Text(
            title2,
            style: GoogleFonts.roboto(
              color: const Color(0xFF6A1B9A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleText('textLogin_1'.tr()),
                    const SizedBox(height: 40),
                    inputEmail('textLogin_2'.tr()),
                    const SizedBox(height: 20),
                    inputPassword('textLogin_3'.tr()),
                    labelForgetPassword('textLogin_4'.tr()),
                    const SizedBox(height: 20),
                    buttonLogin('textLogin_5'.tr(), authViewModel.isLoading),
                    const SizedBox(height: 20),
                    labelDivider('textLogin_6'.tr()),
                    const SizedBox(height: 20),
                    optionalLoginOther(),
                    const SizedBox(height: 20),
                    labelText2('textLogin_7'.tr(), 'textLogin_8'.tr()),
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
                    Text(
                      'are_processing'.tr(),
                      style: GoogleFonts.roboto(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
