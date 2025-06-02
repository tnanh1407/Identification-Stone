import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/views/auth/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _iconLoading = true;

  void handleLogin(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final authProvider = Provider.of<AuthViewModel>(context, listen: false);
    String? error = await authProvider.signIn(
      context,
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget titleText(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.brown,
      ),
    );
  }

  Widget inputEmail(String textHint) {
    return TextFormField(
      style: TextStyle(
        color: Colors.white,
      ),
      controller: _emailController,
      decoration: InputDecoration(
        fillColor: Colors.brown,
        filled: true,
        hintText: textHint,
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget inputPassword(String textHint) {
    return TextField(
      style: TextStyle(
        color: Colors.white,
      ),
      controller: _passwordController,
      obscureText: _iconLoading,
      decoration: InputDecoration(
        fillColor: Colors.brown,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
          borderSide: BorderSide.none,
        ),
        hintText: textHint,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _iconLoading = !_iconLoading;
            });
          },
          icon: Icon(_iconLoading ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }

  Widget labelForgetPasword(String label) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          label,
          style: TextStyle(color: Colors.brown, fontSize: 16),
        ),
      ),
    );
  }

  Widget buttonLogin(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      onPressed: _isLoading
          ? null
          : () {
              handleLogin(context);
            },
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget labelext(String label) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget optinalLoginOther() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.android, size: 30, color: Colors.green),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.apple, size: 30),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.facebook, size: 30, color: Colors.blue),
        ),
      ],
    );
  }

  Widget labelText2(String title1, String title2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title1),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterPage(),
              ),
            );
          },
          child: Text(
            title2,
            style: TextStyle(color: Colors.brown),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleText('textLogin_1'.tr()),
                    const SizedBox(height: 40),
                    inputEmail("textLogin_2".tr()),
                    const SizedBox(height: 20),
                    inputPassword("textLogin_3".tr()),
                    labelForgetPasword("textLogin_4".tr()),
                    const SizedBox(height: 20),
                    buttonLogin("textLogin_5".tr()),
                    const SizedBox(height: 20),
                    labelext("textLogin_6".tr()),
                    const SizedBox(height: 20),
                    optinalLoginOther(),
                    const SizedBox(height: 20),
                    labelText2('textLogin_7'.tr(), 'textLogin_8'.tr())
                  ],
                ),
              ),
            ),
          ),
          // Màn hình loading chồng lên
          if (_isLoading)
            Container(
              color: Color.fromARGB(128, 0, 0, 0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 16), // Khoảng cách giữa vòng tròn và chữ
                    Text(
                      'are_processing'.tr(),
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
