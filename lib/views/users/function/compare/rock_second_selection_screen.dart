import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// THAY ĐỔI: Import các lớp cần thiết
import 'package:rock_classifier/data/models/rock_models.dart';
import 'package:rock_classifier/view_models/rock_view_model.dart';
import 'package:rock_classifier/views/users/function/compare/rock_comparison_result_screen.dart';
// import 'package:rock_classifier/screens/comparison/rock_comparison_result_screen.dart'; // Đảm bảo đường dẫn này đúng

class RockSecondSelectionScreen extends StatefulWidget {
  // THAY ĐỔI: Nhận vào một đối tượng RockModels
  final RockModels firstStone;

  const RockSecondSelectionScreen({super.key, required this.firstStone});

  @override
  State<RockSecondSelectionScreen> createState() => _RockSecondSelectionScreenState();
}

class _RockSecondSelectionScreenState extends State<RockSecondSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  // THAY ĐỔI: Sử dụng RockModels
  List<RockModels> allOtherStones = []; // Danh sách tất cả đá (trừ viên đầu tiên)
  RockModels? secondStone;

  @override
  void initState() {
    super.initState();
    // Sử dụng WidgetsBinding để đảm bảo context có sẵn khi truy cập Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndFilterStones();
    });
  }

  // THAY ĐỔI: Lấy dữ liệu từ ViewModel thay vì Firestore
  void _loadAndFilterStones() {
    // Lấy ViewModel mà không cần lắng nghe thay đổi (chỉ lấy dữ liệu 1 lần)
    final rockViewModel = Provider.of<RockViewModel>(context, listen: false);

    // Lọc ra viên đá đầu tiên khỏi danh sách, sử dụng uid để đảm bảo chính xác
    final filtered = rockViewModel.rocks.where((rock) {
      return rock.uid != widget.firstStone.uid;
    }).toList();

    setState(() {
      allOtherStones = filtered;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Logic tìm kiếm bây giờ hoạt động trên danh sách allOtherStones
    final filteredStones = allOtherStones.where((stone) {
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
              "Mẫu đá thứ nhất đã chọn",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            _buildStoneCard(widget.firstStone, highlight: true),
            const SizedBox(height: 24),
            const Text(
              "Chọn mẫu đá thứ hai để so sánh",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: allOtherStones.isEmpty
                  ? const Center(child: CircularProgressIndicator()) // Hiển thị khi đang tải
                  : ListView.builder(
                      itemCount: filteredStones.length,
                      itemBuilder: (context, index) {
                        final stone = filteredStones[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              secondStone = stone;
                            });
                          },
                          // THAY ĐỔI: So sánh bằng uid
                          child: _buildStoneCard(
                            stone,
                            highlight: secondStone?.uid == stone.uid,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            // Nút "So sánh" chỉ hiện khi đã chọn đá thứ 2
            if (secondStone != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RockComparisonResultScreen(
                          firstStone: widget.firstStone,
                          secondStone: secondStone!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF303A53),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "So sánh",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      title: _buildSearchBar(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
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
          hintText: "Tìm kiếm đá hoặc khoáng sản...",
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
  Widget _buildStoneCard(RockModels stone, {bool highlight = false}) {
    final name = stone.tenDa ?? 'Không rõ';
    final type = stone.loaiDa ?? 'Không rõ';
    // Lấy ảnh đầu tiên một cách an toàn
    final image = stone.hinhAnh.isNotEmpty ? stone.hinhAnh.first : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? Colors.orange.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? Colors.orange : Colors.grey.shade200,
          width: 1.5,
        ),
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
            // Bọc trong Expanded để text dài có thể xuống dòng
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Loại đá: $type',
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
