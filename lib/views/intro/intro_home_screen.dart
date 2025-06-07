import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rock_classifier/views/intro/intro_screen.dart';

// Đổi tên class cho đúng chuẩn Dart (UpperCamelCase)
class IntroHomeScreen extends StatefulWidget {
  const IntroHomeScreen({super.key}); // Thêm const constructor

  @override
  State<IntroHomeScreen> createState() => _IntroHomeScreenState();
}

class _IntroHomeScreenState extends State<IntroHomeScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // Tự động chuyển màn hình sau một khoảng thời gian
    Future.delayed(const Duration(seconds: 3), () {
      // Kiểm tra xem widget còn trên cây không trước khi điều hướng
      if (mounted) {
        Navigator.of(context).pushReplacement(_createRoute());
      }
    });
  }

  // Hàm tạo hiệu ứng Fade khi chuyển màn hình
  Route _createRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => OnboardingScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy theme một lần để tái sử dụng
    final theme = Theme.of(context);

    return Scaffold(
      // SỬA: Lấy màu nền từ theme
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Padding(
          // Thêm padding để nội dung không bị dính sát vào cạnh màn hình
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Đảm bảo bạn có file này trong thư mục assets
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              // SỬA: Dùng key dịch và style từ theme
              Text(
                'splash_screen.greeting'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              // SỬA: Dùng key dịch và style từ theme
              Text(
                'splash_screen.main_title'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // SỬA: Dùng key dịch và style từ theme
              Text(
                'splash_screen.subtitle'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
