import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// THAY ĐỔI: Import các lớp cần thiết
import 'package:rock_classifier/data/models/rock_models.dart';
import 'package:rock_classifier/view_models/rock_view_model.dart';
import 'package:rock_classifier/views/users/function/compare/rock_second_selection_screen.dart'; // Đảm bảo đường dẫn này đúng
// import 'package:rock_classifier/screens/main_screen.dart'; // Đảm bảo đường dẫn này đúng

class RockFirstSelectionScreen extends StatefulWidget {
  const RockFirstSelectionScreen({super.key});

  @override
  State<RockFirstSelectionScreen> createState() => _RockFirstSelectionScreenState();
}

class _RockFirstSelectionScreenState extends State<RockFirstSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  // THAY ĐỔI: Không cần biến firstStone ở đây nữa
  // Map<String, dynamic>? firstStone;

  // THAY ĐỔI: Không cần fetch thủ công nữa
  // List<Map<String, dynamic>> stones = [];

  // @override
  // void initState() {
  //   super.initState();
  //   fetchStones(); // Sẽ được loại bỏ
  // }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // THAY ĐỔI: Lắng nghe ViewModel để lấy dữ liệu
    return Consumer<RockViewModel>(
      builder: (context, viewModel, child) {
        // Lọc danh sách đá dựa trên ô tìm kiếm
        final filteredStones = viewModel.rocks.where((stone) {
          final query = _searchController.text.toLowerCase().trim();
          if (query.isEmpty) return true;

          final name = stone.tenDa?.toLowerCase() ?? '';
          final type = stone.loaiDa?.toLowerCase() ?? '';
          return name.contains(query) || type.contains(query);
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  "Chọn mẫu đá thứ nhất",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: filteredStones.length,
                          itemBuilder: (context, index) {
                            final selectedStone = filteredStones[index];
                            return GestureDetector(
                              onTap: () {
                                // THAY ĐỔI: Điều hướng với đối tượng RockModels
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RockSecondSelectionScreen(
                                      firstStone: selectedStone,
                                    ),
                                  ),
                                );
                              },
                              // THAY ĐỔI: Truyền đối tượng RockModels vào card
                              child: _buildStoneCard(selectedStone),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: _buildSearchBar(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              // Điều hướng về màn hình chính
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => MainScreen()),
              //   (route) => false,
              // );
              Navigator.pop(context); // Pop về màn hình trước đó
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.grey.shade800, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Tìm kiếm đá và khoáng sản...",
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade600),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
        ),
      ),
    );
  }

  // THAY ĐỔI: Nhận vào một đối tượng RockModels
  Widget _buildStoneCard(RockModels stone) {
    final name = stone.tenDa ?? "Không rõ";
    final type = stone.loaiDa ?? "Không rõ";
    final image = stone.hinhAnh.isNotEmpty ? stone.hinhAnh.first : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
                  )
                : Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Loại đá: $type",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
