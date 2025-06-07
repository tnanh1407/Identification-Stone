import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/view_models/theme_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.theme_settings_title'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'settings.theme_mode_label'.tr(),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            // Dùng Card để nhóm các lựa chọn lại
            Card(
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Column(
                    children: [
                      _buildThemeOptionTile(
                        context: context,
                        titleKey: 'settings.theme_mode_system',
                        value: ThemeModeOption.system,
                        groupValue: themeProvider.themeMode.toThemeModeOption(),
                        onChanged: (value) => themeProvider.setThemeMode(value!),
                      ),
                      _buildThemeOptionTile(
                        context: context,
                        titleKey: 'settings.theme_mode_light',
                        value: ThemeModeOption.light,
                        groupValue: themeProvider.themeMode.toThemeModeOption(),
                        onChanged: (value) => themeProvider.setThemeMode(value!),
                      ),
                      _buildThemeOptionTile(
                        context: context,
                        titleKey: 'settings.theme_mode_dark',
                        value: ThemeModeOption.dark,
                        groupValue: themeProvider.themeMode.toThemeModeOption(),
                        onChanged: (value) => themeProvider.setThemeMode(value!),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để tạo một dòng lựa chọn theme
  Widget _buildThemeOptionTile({
    required BuildContext context,
    required String titleKey,
    required ThemeModeOption value,
    required ThemeModeOption groupValue,
    required ValueChanged<ThemeModeOption?> onChanged,
  }) {
    final theme = Theme.of(context);
    return RadioListTile<ThemeModeOption>(
      title: Text(titleKey.tr(), style: theme.textTheme.bodyLarge),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: theme.colorScheme.primary,
    );
  }
}

// THÊM: Cần một hàm mở rộng để chuyển ngược từ ThemeMode về enum tùy chỉnh của chúng ta
// Bạn có thể đặt hàm này ở cuối file theme_provider.dart hoặc ở đây đều được.
extension ThemeModeExtension on ThemeMode {
  ThemeModeOption toThemeModeOption() {
    switch (this) {
      case ThemeMode.light:
        return ThemeModeOption.light;
      case ThemeMode.dark:
        return ThemeModeOption.dark;
      case ThemeMode.system:
      default:
        return ThemeModeOption.system;
    }
  }
}
