import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/view_models/rock_view_model.dart';
import 'package:rock_classifier/views/users/homePageUser/view/article_section.dart';
import 'package:rock_classifier/views/users/homePageUser/view/hero_section.dart';
import 'package:rock_classifier/views/users/homePageUser/view/popular_rocks_section.dart';
import 'package:rock_classifier/views/users/homePageUser/view/rock_category_section.dart';

class HomePageUser extends StatefulWidget {
  const HomePageUser({Key? key}) : super(key: key);

  @override
  State<HomePageUser> createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  @override
  void initState() {
    super.initState();
    // TỐI ƯU: Gom tất cả các lệnh gọi fetch dữ liệu ban đầu vào một Future.microtask.
    // Điều này đảm bảo tất cả các hành động thay đổi state sẽ được thực hiện
    // một cách an toàn sau khi widget đã được khởi tạo xong.
    Future.microtask(() {
      // listen: false là bắt buộc trong initState
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final rockViewModel = Provider.of<RockViewModel>(context, listen: false);

      // Tải dữ liệu người dùng
      authViewModel.loadCurrentUser();

      // Tải danh sách các loại đá
      // Thêm kiểm tra để tránh fetch lại dữ liệu không cần thiết nếu nó đã có sẵn.
      if (rockViewModel.rocks.isEmpty) {
        rockViewModel.fetchRocks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SearchBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverAnimatedSection(child: HeroSection(), delay: 100),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverAnimatedSection(child: ArticleSection(), delay: 200),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const SliverAnimatedSection(child: PopularRocksSection(), delay: 300),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const SliverAnimatedSection(child: RockCategorySection(), delay: 400),
          ],
        ),
      ),
    );
  }
}

// Không hiệu ứng chớp khi cuộn
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(context, child, details) => child;
}

// Animation cho từng section khi cuộn vào
class SliverAnimatedSection extends StatefulWidget {
  final Widget child;
  final int delay;

  const SliverAnimatedSection({required this.child, this.delay = 0, Key? key}) : super(key: key);

  @override
  State<SliverAnimatedSection> createState() => _SliverAnimatedSectionState();
}

class _SliverAnimatedSectionState extends State<SliverAnimatedSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

// Thanh tìm kiếm
class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 8), // Tăng padding top một chút
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Ví dụ điều hướng đến màn hình tìm kiếm
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => SearchScreen()),
                // );
                print("Search bar tapped");
              },
              child: Container(
                height: 48, // Tăng chiều cao một chút
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7), // Màu nền xám nhẹ
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Tìm kiếm đá, khoáng sản...",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              final user = authViewModel.currentUser;
              final avatarUrl = user?.avatar;

              if (authViewModel.isLoading && user == null) {
                return const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                );
              }

              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  // Ví dụ điều hướng đến màn hình cài đặt
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => SettingsScreen()),
                  // );
                  print("Avatar tapped");
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty) ? Icon(Icons.person, color: Colors.grey[600], size: 28) : null,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
