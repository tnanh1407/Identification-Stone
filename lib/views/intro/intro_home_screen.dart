import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/views/admin/main_page_admin.dart';
import 'package:rock_classifier/views/auth/login_page.dart';
import 'package:rock_classifier/views/intro/intro_screen.dart';
import 'package:rock_classifier/views/users/main_page_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroHomeScreen extends StatefulWidget {
  const IntroHomeScreen({super.key});

  @override
  State<IntroHomeScreen> createState() => _IntroHomeScreenState();
}

class _IntroHomeScreenState extends State<IntroHomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatusAndNavigate();
  }

  Future<void> _checkStatusAndNavigate() async {
    // Đợi 2-3 giây để hiển thị màn hình intro
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final authViewModel = context.read<AuthViewModel>();

    // Kiểm tra xem người dùng đã xem onboarding chưa
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding) {
      // 1. Lần đầu vào app -> Đi đến Onboarding
      // Dùng PageRouteBuilder để có hiệu ứng
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      // 2. Đã xem onboarding rồi -> Kiểm tra trạng thái đăng nhập
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // 2a. Đã đăng nhập -> Tải dữ liệu và vào trang chính
        await authViewModel.loadCurrentUser();
        if (!mounted) return;

        Widget homePage;
        if (authViewModel.isAdmin() || authViewModel.isSuperUser()) {
          homePage = const MainPageAdmin();
        } else {
          homePage = const MainPageUser();
        }
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => homePage));
      } else {
        // 2b. Chưa đăng nhập -> Vào trang Login
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI của màn hình intro giữ nguyên như bạn đã làm
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/humg_logo.jpg',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 24),
              Text(
                'splash_screen.greeting'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary),
              ),
              const SizedBox(height: 8),
              Text(
                'splash_screen.main_title'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 16),
              Text(
                'splash_screen.subtitle'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
