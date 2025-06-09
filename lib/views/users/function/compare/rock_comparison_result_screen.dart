import 'package:flutter/material.dart';
import 'package:rock_classifier/data/models/rock_models.dart';
// import 'package:stonelens/views/home/bottom_nav_bar.dart';

class RockComparisonResultScreen extends StatelessWidget {
  final RockModels firstStone;
  final RockModels secondStone;

  const RockComparisonResultScreen({
    super.key,
    required this.firstStone,
    required this.secondStone,
  });

  @override
  Widget build(BuildContext context) {
    // Map các thuộc tính với icon và nhãn để so sánh
    final Map<String, Map<String, dynamic>> comparisonProperties = {
      'loaiDa': {'label': 'Loại đá', 'icon': Icons.category_outlined},
      'nhomDa': {'label': 'Nhóm đá', 'icon': Icons.group_work_outlined},
      'dacDiem': {'label': 'Đặc điểm', 'icon': Icons.star_border_outlined},
      'thanhPhanHoaHoc': {'label': 'Thành phần hóa học', 'icon': Icons.science_outlined},
      'doCung': {'label': 'Độ cứng', 'icon': Icons.fitness_center_outlined},
      'kienTruc': {'label': 'Kiến trúc', 'icon': Icons.architecture_outlined},
      'cauTao': {'label': 'Cấu tạo', 'icon': Icons.layers_outlined},
    };

    // =======================================================================
    // >> LOGIC MỚI: Phân tích sự giống và khác nhau <<
    // =======================================================================
    List<String> similarAttributes = [];
    List<String> differentAttributes = [];

    comparisonProperties.forEach((key, value) {
      final val1 = _getStonePropertyValue(firstStone, key);
      final val2 = _getStonePropertyValue(secondStone, key);
      // Chỉ xét các thuộc tính có giá trị
      if (val1 != null && val1.isNotEmpty && val2 != null && val2.isNotEmpty) {
        if (val1 == val2) {
          similarAttributes.add(value['label']); // Thêm nhãn của thuộc tính
        } else {
          differentAttributes.add(value['label']);
        }
      }
    });
    // =======================================================================

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        // Bọc toàn bộ body trong SingleChildScrollView
        child: Column(
          children: [
            // Phần so sánh chi tiết
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStoneColumn(
                  context,
                  stone: firstStone,
                  comparisonProperties: comparisonProperties,
                  otherStone: secondStone,
                ),
                VerticalDivider(color: Colors.grey.shade300, width: 1),
                _buildStoneColumn(
                  context,
                  stone: secondStone,
                  comparisonProperties: comparisonProperties,
                  otherStone: firstStone,
                ),
              ],
            ),

            // =======================================================================
            // >> WIDGET MỚI: Hiển thị nhận xét chung <<
            // =======================================================================
            ComparisonSummaryCard(
              similarCount: similarAttributes.length,
              similarAttributes: similarAttributes,
              differentAttributes: differentAttributes,
            ),
            // =======================================================================
          ],
        ),
      ),
    );
  }

  // Widget xây dựng một cột thông tin cho một viên đá (không thay đổi)
  Widget _buildStoneColumn(
    BuildContext context, {
    required RockModels stone,
    required Map<String, Map<String, dynamic>> comparisonProperties,
    required RockModels otherStone,
  }) {
    return Expanded(
      child: Column(
        // Bỏ SingleChildScrollView ở đây vì đã có ở ngoài
        children: [
          _StoneHeader(stone: stone),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comparisonProperties.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
            itemBuilder: (context, index) {
              String key = comparisonProperties.keys.elementAt(index);
              String label = comparisonProperties[key]!['label'];
              IconData icon = comparisonProperties[key]!['icon'];
              String? value = _getStonePropertyValue(stone, key);
              String? otherValue = _getStonePropertyValue(otherStone, key);
              bool areEqual = (value != null && value.isNotEmpty) && (value == otherValue);

              return _PropertyTile(
                icon: icon,
                label: label,
                value: value,
                isSimilar: areEqual,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper để lấy giá trị thuộc tính (không thay đổi)
  String? _getStonePropertyValue(RockModels stone, String key) {
    switch (key) {
      case 'loaiDa':
        return stone.loaiDa;
      case 'nhomDa':
        return stone.nhomDa;
      case 'dacDiem':
        return stone.dacDiem;
      case 'thanhPhanHoaHoc':
        return stone.thanhPhanHoaHoc;
      case 'doCung':
        return stone.doCung;
      case 'kienTruc':
        return stone.kienTruc;
      case 'cauTao':
        return stone.cauTao;
      default:
        return null;
    }
  }

  // AppBar (không thay đổi)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.grey.shade100,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF303A53),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "VS",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.black, size: 26),
          onPressed: () {/* Về trang chủ */},
        ),
      ],
    );
  }
}

// Widget header của mỗi cột (không thay đổi)
class _StoneHeader extends StatelessWidget {
  final RockModels stone;
  const _StoneHeader({required this.stone});
  @override
  Widget build(BuildContext context) {
    /* ... Giữ nguyên code ... */
    String image = stone.hinhAnh.isNotEmpty ? stone.hinhAnh.first : '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.isNotEmpty
                ? Image.network(image, height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholderImage())
                : _buildPlaceholderImage(),
          ),
          const SizedBox(height: 12),
          Text(
            stone.tenDa ?? 'Không rõ',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF303A53)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    /* ... Giữ nguyên code ... */
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
    );
  }
}

// Widget mỗi hàng thuộc tính (không thay đổi)
class _PropertyTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isSimilar;
  const _PropertyTile({required this.icon, required this.label, required this.value, this.isSimilar = false});
  @override
  Widget build(BuildContext context) {
    /* ... Giữ nguyên code ... */
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isSimilar ? Colors.green.withOpacity(0.1) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value ?? "—", style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }
}

// =======================================================================
// >> WIDGET MỚI: CARD NHẬN XÉT CHUNG <<
// =======================================================================
class ComparisonSummaryCard extends StatelessWidget {
  final int similarCount;
  final List<String> similarAttributes;
  final List<String> differentAttributes;

  const ComparisonSummaryCard({
    super.key,
    required this.similarCount,
    required this.similarAttributes,
    required this.differentAttributes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200), boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        )
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize_outlined, color: Color(0xFF303A53)),
              const SizedBox(width: 8),
              const Text(
                "Nhận xét chung",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF303A53),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            "Hai mẫu đá này có $similarCount điểm tương đồng và ${differentAttributes.length} điểm khác biệt chính.",
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 16),
          if (similarAttributes.isNotEmpty)
            _buildAttributeList(
              "Điểm tương đồng:",
              similarAttributes,
              Icons.check_circle_outline,
              Colors.green.shade700,
            ),
          if (differentAttributes.isNotEmpty)
            _buildAttributeList(
              "Điểm khác biệt:",
              differentAttributes,
              Icons.highlight_off_outlined,
              Colors.red.shade700,
            ),
        ],
      ),
    );
  }

  Widget _buildAttributeList(
    String title,
    List<String> attributes,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...attributes.map((attr) => Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: iconColor),
                    const SizedBox(width: 8),
                    Expanded(child: Text(attr, style: const TextStyle(fontSize: 15))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
