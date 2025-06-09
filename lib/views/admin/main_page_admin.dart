  import 'package:easy_localization/easy_localization.dart';
  import 'package:flutter/material.dart';
  import 'package:rock_classifier/views/admin/home_page_admin.dart'; // Sửa lỗi chính tả Views -> views
  import 'package:rock_classifier/views/admin/information_page_admin.dart'; // Sửa lỗi chính tả Views -> views

  class MainPageAdmin extends StatefulWidget {
    const MainPageAdmin({super.key});

    @override
    State<MainPageAdmin> createState() => _MainPageAdminState();
  }

  class _MainPageAdminState extends State<MainPageAdmin> {
    int _selectedIndex = 0;

    static const List<Widget> _widgetOptions = [
      HomePageAdmin(),
      InformationPageAdmin(),
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    @override
    Widget build(BuildContext context) {
      // Không cần lấy theme ở đây vì BottomNavigationBar đã tự động lấy từ theme toàn cục

      return Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          // Thêm key để AnimatedSwitcher nhận diện đúng widget con khi thay đổi
          child: IndexedStack(
            key: ValueKey<int>(_selectedIndex),
            index: _selectedIndex,
            children: _widgetOptions,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              // THAY ĐỔI: Sử dụng key 'main_nav.home'
              label: 'main_nav.home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              // THAY ĐỔI: Sử dụng key 'main_nav.settings'
              label: 'main_nav.settings'.tr(),
            ),
          ],
        ),
      );
    }
  }
