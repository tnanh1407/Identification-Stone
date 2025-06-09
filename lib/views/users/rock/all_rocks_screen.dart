// lib/views/all_rocks/all_rocks_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/rock_models.dart';
import 'package:rock_classifier/data/services/favorite_service.dart';
import 'package:rock_classifier/view_models/rock_view_model.dart';
import 'package:rock_classifier/views/users/rock/stone_detail_screen.dart';

class AllRocksScreen extends StatefulWidget {
  const AllRocksScreen({super.key});

  @override
  State<AllRocksScreen> createState() => _AllRocksScreenState();
}

class _AllRocksScreenState extends State<AllRocksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final viewModel = context.read<RockViewModel>();
      viewModel.resetAllFilters();
      _searchController.clear();
      _searchController.addListener(() {
        viewModel.searchAllRocks(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  void _showSortOptions(BuildContext context) {
    // Lấy viewModel một lần ở đây để sử dụng trong builder
    final viewModel = context.read<RockViewModel>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, // Nền trắng cho sheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // Sử dụng một map để định nghĩa chi tiết cho mỗi tùy chọn
        final options = {
          RockSortOption.tenDa: {
            'title': 'Tên đá (A-Z)',
            'icon': Icons.sort_by_alpha,
          },
          RockSortOption.nhomDa: {
            'title': 'Nhóm đá (A-Z)',
            'icon': Icons.category_outlined,
          },
          RockSortOption.loaiDa: {
            'title': 'Loại đá (A-Z)',
            'icon': Icons.merge_type,
          },
        };

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "Tay cầm" (Grabber handle)
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              // Tiêu đề
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Sắp xếp',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              // Dùng Column để tạo danh sách các tùy chọn
              Column(
                children: options.entries.map((entry) {
                  final option = entry.key;
                  final details = entry.value;
                  final isSelected = viewModel.currentSortOption == option;

                  return ListTile(
                    // Hiệu ứng nền khi được chọn
                    tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      details['icon'] as IconData,
                      // Màu icon thay đổi khi được chọn
                      color: isSelected ? Colors.blue : Colors.grey[600],
                    ),
                    title: Text(
                      details['title'] as String,
                      style: TextStyle(
                        // Màu chữ thay đổi khi được chọn
                        color: isSelected ? Colors.blue : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    // Thêm dấu check khi được chọn
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                    onTap: () {
                      viewModel.sortAllRocks(option);
                      Navigator.of(ctx).pop();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // SỬA: Thêm màu nền tinh tế cho toàn màn hình
    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền xám rất nhẹ
      appBar: AppBar(
        title: const Text('Tất cả các loại đá'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
            tooltip: 'Sắp xếp',
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm được giữ nguyên
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, loại đá...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Danh sách đã được nâng cấp
          Expanded(
            child: Consumer<RockViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.rocks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final displayedRocks = viewModel.rocks;
                if (displayedRocks.isEmpty) {
                  return Center(
                    child: Text(
                      _searchController.text.isEmpty ? 'Không có loại đá nào.' : 'Không tìm thấy kết quả.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }
                // SỬA: Dùng ListView.builder thay vì ListView.separated
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: displayedRocks.length,
                  itemBuilder: (context, index) {
                    final rock = displayedRocks[index];
                    // Mỗi mục giờ là một Card riêng biệt
                    return RockListItem(rock: rock);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
//   WIDGET ROCKLISTITEM ĐÃ ĐƯỢC THIẾT KẾ LẠI HOÀN TOÀN
// =======================================================
class RockListItem extends StatelessWidget {
  final RockModels rock;
  const RockListItem({super.key, required this.rock});

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoneDetailScreen(rock: rock),
      ),
    );
  }

  void _handleFavoriteToggle(BuildContext context, bool isFavorite) {
    final favoriteService = context.read<FavoriteService>();
    if (isFavorite) {
      favoriteService.removeFavorite(rock.uid);
    } else {
      favoriteService.addFavorite(rock.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteService = context.watch<FavoriteService>();
    final imageUrl = rock.hinhAnh.isNotEmpty ? rock.hinhAnh[0] : null;

    // SỬA: Bọc trong một Container để tạo hiệu ứng Card
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Phần hình ảnh với nút yêu thích chồng lên
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox.expand(
                          child: (imageUrl != null)
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: Colors.grey[200], child: Icon(Icons.broken_image, color: Colors.grey[400])),
                                )
                              : Container(color: Colors.grey[200], child: Icon(Icons.image_not_supported, color: Colors.grey[400])),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: StreamBuilder<bool>(
                          stream: favoriteService.rockFavoriteStatusStream(rock.uid),
                          builder: (context, snapshot) {
                            final isFavorite = snapshot.data ?? false;
                            return InkResponse(
                              onTap: () => _handleFavoriteToggle(context, isFavorite),
                              radius: 18,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Phần thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        rock.tenDa ?? 'Chưa có tên',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (rock.tenTiengViet != null && rock.tenTiengViet!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            '(${rock.tenTiengViet})',
                            style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Hiển thị thông tin phụ dưới dạng "Tag"
                      Row(
                        children: [
                          _buildInfoTag(Icons.category_outlined, rock.nhanhDa ?? 'Chưa rõ'),
                          const SizedBox(width: 8),
                          _buildInfoTag(Icons.merge_type, rock.loaiDa ?? 'Chưa rõ', color: Colors.blue.shade50),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget phụ để tạo các "Tag" thông tin
  Widget _buildInfoTag(IconData icon, String text, {Color color = const Color(0xFFF0F0F0)}) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey[700]),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
