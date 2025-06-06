import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/user_models.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';

void editUserInfoBottomSheet(BuildContext context, UserModels user) {
  final fullNameController = TextEditingController(text: user.fullName ?? '');
  final addressController = TextEditingController(text: user.address ?? '');
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return BottomSheetContent(
        formKey: formKey,
        fullNameController: fullNameController,
        addressController: addressController,
        user: user,
      );
    },
  );
}

class BottomSheetContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController addressController;
  final UserModels user;

  const BottomSheetContent({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.addressController,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DragHandle(),
            TitleText(),
            const SizedBox(height: 20),
            FullNameField(controller: fullNameController),
            const SizedBox(height: 20),
            AddressField(controller: addressController),
            const SizedBox(height: 20),
            SaveButton(
              formKey: formKey,
              fullNameController: fullNameController,
              addressController: addressController,
              user: user,
            ),
          ],
        ),
      ),
    );
  }
}

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 5,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'textEditAdmin_dialog1'.tr(),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class FullNameField extends StatelessWidget {
  final TextEditingController controller;

  const FullNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: Theme.of(context).textTheme.titleSmall,
      validator: (value) => value == null || value.isEmpty ? 'textEditAdmin_dialog5'.tr() : null,
      decoration: InputDecoration(
        labelText: 'textEditAdmin_dialog2'.tr(),
        labelStyle: Theme.of(context).textTheme.titleSmall,
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

class AddressField extends StatelessWidget {
  final TextEditingController controller;

  const AddressField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: Theme.of(context).textTheme.titleSmall,
      decoration: InputDecoration(
        labelText: 'textEditAdmin_dialog3'.tr(),
        labelStyle: Theme.of(context).textTheme.titleSmall,
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

class SaveButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController addressController;
  final UserModels user;

  const SaveButton({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.addressController,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              final updateUser = UserModels(
                uid: user.uid,
                email: user.email,
                role: user.role,
                createdAt: user.createdAt,
                fullName: fullNameController.text.trim(),
                address: addressController.text.trim(),
                avatar: user.avatar,
              );

              await authViewModel.updateUser(updateUser);
              Navigator.of(context).pop();
              if (authViewModel.errorMessage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('textEditAdmin_dialog6'.tr()),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Không thành công! ${authViewModel.errorMessage}'),
                  ),
                );
              }
            }
          },
          icon: const Icon(
            Icons.save,
            color: Colors.white,
          ),
          label: Text(
            'textEditAdmin_dialog4'.tr(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
    );
  }
}
