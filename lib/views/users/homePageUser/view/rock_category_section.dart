// lib/views/users/homePageUser/view/rock_category_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/rock_models.dart';
import 'package:rock_classifier/data/services/favorite_service.dart';
import 'package:rock_classifier/view_models/rock_view_model.dart';
import 'package:rock_classifier/views/users/rock/all_rocks_screen.dart';

class RockCategorySection extends StatefulWidget {
  const RockCategorySection({super.key});

  @override
  State<RockCategorySection> createState() => _RockCategorySectionState();
}

class _RockCategorySectionState extends State<RockCategorySection> {
  String selectedCategory = "Tất cả";

  @override
  void initState() {
    super.initState();
    // Vẫn fetch dữ liệu nếu chưa có
    final rockViewModel = Provider.of<RockViewModel>(context, listen: false);
    if (rockViewModel.rocks.isEmpty) {
      Future.microtask(() => rockViewModel.fetchRocks());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Chỉ "watch" để lấy dữ liệu, không thay đổi nó nữa
    final viewModel = context.watch<RockViewModel>();

    if (viewModel.isLoading && viewModel.rocks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Lọc dữ liệu ngay tại đây, không thay đổi state của ViewModel
    final List<RockModels> filteredRocks;
    if (selectedCategory == "Tất cả") {
      // Lấy tối đa 6-8 mục để hiển thị trên trang chủ cho đẹp
      filteredRocks = viewModel.rocks.take(6).toList();
    } else {
      filteredRocks = viewModel.rocks.where((rock) => rock.nhanhDa == selectedCategory).toList();
    }

    final categories = viewModel.uniqueNhanhDaCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8, top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Các nhóm nhánh chính", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AllRocksScreen()));
                },
                child: const Text("Xem tất cả", style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        _buildCategoryChips(categories),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: filteredRocks.length,
            itemBuilder: (context, index) {
              final rock = filteredRocks[index];
              return RockCard(rock: rock);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () {
              // Chỉ thay đổi state cục bộ của widget này
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF303A53) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RockCard extends StatelessWidget {
  final RockModels rock;
  const RockCard({super.key, required this.rock});

  void _navigateToDetail(BuildContext context) {
    // ...
  }

  void _handleFavoriteToggle(BuildContext context, bool isFavorite) {
    final favoriteService = Provider.of<FavoriteService>(context, listen: false);
    if (isFavorite) {
      favoriteService.removeFavorite(rock.uid);
    } else {
      favoriteService.addFavorite(rock.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteService = Provider.of<FavoriteService>(context, listen: false);
    final imageUrl = rock.hinhAnh.isNotEmpty ? rock.hinhAnh[0] : null;

    // SỬA: Thay thế GestureDetector + Card bằng một Container duy nhất
    return Container(
      // Decoration để tạo hình dạng, màu sắc và bóng đổ
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Lớp bóng thứ nhất (mờ và rộng, tạo cảm giác "glow")
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8), // Đẩy bóng xuống dưới
          ),
          // Lớp bóng thứ hai (đậm và hẹp, tạo độ sâu ngay cạnh thẻ)
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      // Dùng Material để có hiệu ứng ripple khi nhấn
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetail(context),
          child: Stack(
            children: [
              // Nội dung của thẻ (Column) được đặt bên trong ClipRRect
              // để đảm bảo các góc của ảnh cũng được bo tròn
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phần hình ảnh
                    SizedBox(
                      width: double.infinity,
                      height: 110,
                      child: (imageUrl != null)
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(color: Colors.grey[200], child: Icon(Icons.broken_image, color: Colors.grey[400]));
                              },
                            )
                          : Container(color: Colors.grey[200], child: Icon(Icons.image_not_supported, color: Colors.grey[400])),
                    ),
                    // Phần text
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(rock.tenDa ?? 'Chưa có tên',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (rock.tenTiengViet != null && rock.tenTiengViet!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text('(${rock.tenTiengViet})',
                                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.category_outlined, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(rock.nhanhDa ?? 'Chưa phân loại',
                                      style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Nút yêu thích (giữ nguyên)
              Positioned(
                top: 95,
                right: 8,
                child: StreamBuilder<bool>(
                  stream: favoriteService.rockFavoriteStatusStream(rock.uid),
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
                    return Container(
                      width: 36,
                      height: 36,
                      decoration:
                          const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _handleFavoriteToggle(context, isFavorite),
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey, size: 20),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
