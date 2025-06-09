import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rock_classifier/views/users/homePageUser/home_page_user.dart';
import 'package:rock_classifier/views/users/setting_page_user.dart';

class MainPageUser extends StatefulWidget {
  const MainPageUser({super.key});

  @override
  State<MainPageUser> createState() => _MainPageUserState();
}

class _MainPageUserState extends State<MainPageUser> {
  int _pageIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePageUser(),
    SettingPageUser(),
  ];

  void _onNavBarItemTapped(int navIndex) {
    if (navIndex == 1) return;

    setState(() {
      _pageIndex = (navIndex > 1) ? 1 : 0;
    });
  }

// Chức năng gọi camera
  void _onCenterButtonPressed() {
    print("Nút camera ở giữa được nhấn!");
    // Hiển thị một thông báo tạm thời
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng nhận dạng đang được gọi...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body sẽ tự động chuyển đổi giữa các trang với hiệu ứng mờ dần
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_pageIndex],
      ),

      // Sử dụng cấu trúc Stack giống như widget BottomNavBar của bạn
      bottomNavigationBar: Stack(
        // Cần clipBehavior.none để nút nổi có thể tràn ra ngoài
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: 'main_nav.home'.tr(),
              ),
              // Mục ở giữa để tạo khoảng trống, không có icon và label
              const BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: 'main_nav.settings'.tr(),
              ),
            ],
            currentIndex: (_pageIndex == 1) ? 2 : 0,
            onTap: _onNavBarItemTapped,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
          ),

          // 2. Nút nổi được đặt lên trên
          Positioned(
            // Đẩy nút lên trên một chút so với thanh điều hướng
            bottom: 20,
            child: GestureDetector(
              onTap: _onCenterButtonPressed,
              child: Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Color(0xFF8C89F8), // Màu tím giống ví dụ của bạn
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
