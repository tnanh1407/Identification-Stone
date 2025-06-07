import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/Core/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/view_models/news_view_model.dart';
import 'package:rock_classifier/view_models/rock_view_model.dart';
import 'package:rock_classifier/view_models/theme_provider.dart';
import 'package:rock_classifier/view_models/user_list_view_model.dart';
import 'package:rock_classifier/views/intro/intro_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'), // Thêm fallback locale
      child: MultiProvider(
        providers: [
          // SỬA: Không cần các Provider cho Service nữa, vì ViewModel đã khởi tạo chúng
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => UserListViewModel()),
          ChangeNotifierProvider(create: (_) => RockViewModel()),
          ChangeNotifierProvider(create: (_) => NewsViewModel()),
        ],
        child: const MyApp(), // Thêm const
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Thêm const constructor

  @override
  Widget build(BuildContext context) {
    // SỬA: Lắng nghe sự thay đổi của ThemeProvider
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

          // SỬA: Áp dụng theme động
          themeMode: themeProvider.themeMode, // QUAN TRỌNG: Sử dụng chế độ từ provider
          theme: lightTheme, // Theme sẽ được dùng khi chế độ là Light
          darkTheme: darkTheme, // Theme sẽ được dùng khi chế độ là Dark

          debugShowCheckedModeBanner: false,
          home: const IntroHomeScreen(), // Thêm const
        );
      },
    );
  }
}
