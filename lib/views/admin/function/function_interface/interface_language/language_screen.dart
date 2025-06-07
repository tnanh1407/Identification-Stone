import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  void _changeLanguage(String languageCode) {
    // EasyLocalization sẽ tự động build lại widget khi locale thay đổi.
    context.setLocale(Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLanguageCode = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        // THAY ĐỔI: Sử dụng key dịch có cấu trúc
        title: Text("settings.change_language_title".tr()),
        // flexibleSpace là một custom style, ta giữ lại nhưng dùng màu từ theme
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.background,
      body: ListView(
        children: [
          _buildLanguageTile(
            context: context,
            // THAY ĐỔI: Sử dụng key dịch có cấu trúc
            title: 'settings.vietnamese'.tr(),
            languageCode: 'vi',
            isSelected: currentLanguageCode == 'vi',
            onTap: () => _changeLanguage('vi'),
          ),
          const Divider(height: 1),
          _buildLanguageTile(
            context: context,
            // THAY ĐỔI: Sử dụng key dịch có cấu trúc
            title: 'settings.english'.tr(),
            languageCode: 'en',
            isSelected: currentLanguageCode == 'en',
            onTap: () => _changeLanguage('en'),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String title,
    required String languageCode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.titleMedium,
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withOpacity(0.08),
    );
  }
}
