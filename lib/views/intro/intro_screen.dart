import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:rock_classifier/views/auth/login_page.dart'; // Import trang đăng nhập

// =======================================================================
//                           MÀN HÌNH ONBOARDING
// =======================================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDone() {
    // Sử dụng pushReplacement để người dùng không thể quay lại màn hình onboarding
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Danh sách các trang onboarding, bạn có thể thêm/bớt ở đây
    final onboardingPages = [
      _buildOnboardingPage(
        context: context,
        imagePath: 'assets/intro1.png', // Thay bằng đường dẫn ảnh của bạn
        titleKey: 'onboarding.page1_title',
        subtitleKey: 'onboarding.page1_subtitle',
      ),
      _buildOnboardingPage(
        context: context,
        imagePath: 'assets/intro2.png', // Thay bằng đường dẫn ảnh của bạn
        titleKey: 'onboarding.page2_title',
        subtitleKey: 'onboarding.page2_subtitle',
      ),
      _buildOnboardingPage(
        context: context,
        imagePath: 'assets/intro3.png', // Thay bằng đường dẫn ảnh của bạn
        titleKey: 'onboarding.page3_title',
        subtitleKey: 'onboarding.page3_subtitle',
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Nút Bỏ qua
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onDone,
                child: Text('onboarding.skip_button'.tr()),
              ),
            ),
            // Phần nội dung các trang
            Expanded(
              child: PageView(
                controller: _pageController,
                children: onboardingPages,
              ),
            ),
            // Dấu chấm chỉ báo trang
            DotsIndicator(
              dotsCount: onboardingPages.length,
              // SỬA: Chuyển _currentPage thành double
              position: _currentPage.toDouble(),
              decorator: DotsDecorator(
                color: theme.colorScheme.secondary.withOpacity(0.3),
                activeColor: theme.colorScheme.primary,
                size: const Size.square(9.0),
                activeSize: const Size(18.0, 9.0),
                activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
            ),
            const SizedBox(height: 24),
            // Nút Tiếp/Bắt đầu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (_currentPage == onboardingPages.length - 1) {
                    _onDone();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  _currentPage == onboardingPages.length - 1 ? 'onboarding.done_button'.tr() : 'onboarding.next_button'.tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để xây dựng một trang onboarding
  Widget _buildOnboardingPage({
    required BuildContext context,
    required String imagePath,
    required String titleKey,
    required String subtitleKey,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 250, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 150)),
          const SizedBox(height: 48),
          Text(
            titleKey.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitleKey.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
