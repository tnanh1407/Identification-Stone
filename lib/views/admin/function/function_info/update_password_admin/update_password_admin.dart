import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';

class UpdatePasswordAdmin extends StatefulWidget {
  const UpdatePasswordAdmin({super.key});

  @override
  State<UpdatePasswordAdmin> createState() => _UpdatePasswordAdminState();
}

class _UpdatePasswordAdminState extends State<UpdatePasswordAdmin> {
  final TextEditingController _passOldController = TextEditingController();
  final TextEditingController _passNewController = TextEditingController();
  final TextEditingController _passConfirmController = TextEditingController();

  @override
  void dispose() {
    _passOldController.dispose();
    _passNewController.dispose();
    _passConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
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
            title: Text("textUpdatePsAdmin5".tr(), style: Theme.of(context).textTheme.titleLarge),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                PasswordFormSection(
                  passOldController: _passOldController,
                  passNewController: _passNewController,
                  passConfirmController: _passConfirmController,
                  onSubmit: () => PasswordHandler.handlePass(
                    context,
                    authViewModel,
                    _passOldController,
                    _passNewController,
                    _passConfirmController,
                  ),
                ),
                LoadingIndicator(isLoading: authViewModel.isLoading),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PasswordFormSection extends StatelessWidget {
  final TextEditingController passOldController;
  final TextEditingController passNewController;
  final TextEditingController passConfirmController;
  final VoidCallback onSubmit;

  const PasswordFormSection({
    super.key,
    required this.passOldController,
    required this.passNewController,
    required this.passConfirmController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PasswordTextField(
                controller: passOldController,
                hintText: "textUpdatePsAdmin8".tr(),
              ),
              const SizedBox(height: 16),
              PasswordTextField(
                controller: passNewController,
                hintText: "textUpdatePsAdmin9".tr(),
              ),
              const SizedBox(height: 16),
              PasswordTextField(
                controller: passConfirmController,
                hintText: "textUpdatePsAdmin10".tr(),
              ),
              const SizedBox(height: 24),
              SubmitButton(onSubmit: onSubmit),
            ],
          ),
        ),
      ],
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      style: Theme.of(context).textTheme.titleSmall,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: Theme.of(context).textTheme.titleSmall,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
          onPressed: _toggleVisibility,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: Colors.brown, width: 2),
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final VoidCallback onSubmit;

  const SubmitButton({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
        ),
        onPressed: Provider.of<AuthViewModel>(context, listen: false).isLoading ? null : onSubmit,
        child: Text(
          "textUpdatePsAdmin6".tr(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final bool isLoading;

  const LoadingIndicator({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox.shrink();
  }
}

class PasswordHandler {
  static Future<void> handlePass(
    BuildContext context,
    AuthViewModel authViewModel,
    TextEditingController passOldController,
    TextEditingController passNewController,
    TextEditingController passConfirmController,
  ) async {
    final oldPass = passOldController.text.trim();
    final newPass = passNewController.text.trim();
    final confirmPass = passConfirmController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('textUpdatePsAdmin1'.tr())),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('textUpdatePsAdmin2'.tr())),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('textUpdatePsAdmin3'.tr())),
      );
      return;
    }

    final error = await authViewModel.updatePassword(oldPass, newPass);
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('textUpdatePsAdmin4'.tr())),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
}
