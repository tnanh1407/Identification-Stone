import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:rock_classifier/data/models/rock_models.dart';
import 'package:rock_classifier/data/services/ai_service.dart';

class RockComparisonResultScreen extends StatefulWidget {
  final RockModels firstStone;
  final RockModels secondStone;

  const RockComparisonResultScreen({
    super.key,
    required this.firstStone,
    required this.secondStone,
  });

  @override
  State<RockComparisonResultScreen> createState() => _RockComparisonResultScreenState();
}

class _RockComparisonResultScreenState extends State<RockComparisonResultScreen> {
  late Future<String> _aiSummaryFuture;
  final AiComparisonService _aiService = AiComparisonService();

  @override
  void initState() {
    super.initState();
    _aiSummaryFuture = _aiService.getComparisonSummary(
      widget.firstStone,
      widget.secondStone,
    );
  }

  @override
  Widget build(BuildContext context) {
    // =======================================================================
    // >> SỬA ĐỔI 1: Mở rộng danh sách để hiển thị TẤT CẢ thuộc tính <<
    // =======================================================================
    final Map<String, Map<String, dynamic>> comparisonProperties = {
      'tenTiengViet': {'label': 'Tên tiếng Việt', 'icon': Icons.translate_outlined},
      'loaiDa': {'label': 'Loại đá', 'icon': Icons.category_outlined},
      'nhomDa': {'label': 'Nhóm đá', 'icon': Icons.group_work_outlined},
      'nhanhDa': {'label': 'Nhánh đá', 'icon': Icons.call_split_outlined},
      'mauSac': {'label': 'Màu sắc', 'icon': Icons.color_lens_outlined},
      'doCung': {'label': 'Độ cứng (Mohs)', 'icon': Icons.fitness_center_outlined},
      'matDo': {'label': 'Mật độ', 'icon': Icons.scale_outlined},
      'kienTruc': {'label': 'Kiến trúc', 'icon': Icons.architecture_outlined},
      'cauTao': {'label': 'Cấu tạo', 'icon': Icons.layers_outlined},
      'thanhPhanHoaHoc': {'label': 'Thành phần hóa học', 'icon': Icons.science_outlined},
      'thanhPhanKhoangSan': {'label': 'Thành phần khoáng sản', 'icon': Icons.grain_outlined},
      'dacDiem': {'label': 'Đặc điểm', 'icon': Icons.star_border_outlined},
      'mieuTa': {'label': 'Miêu tả', 'icon': Icons.description_outlined},
      'congDung': {'label': 'Công dụng', 'icon': Icons.build_outlined},
      'noiPhanBo': {'label': 'Nơi phân bố', 'icon': Icons.map_outlined},
      'motSoKhoangSanLienQuan': {'label': 'Khoáng sản liên quan', 'icon': Icons.link_outlined},
    };

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header (không đổi)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _StoneHeader(stone: widget.firstStone)),
                Expanded(child: _StoneHeader(stone: widget.secondStone)),
              ],
            ),
            const SizedBox(height: 16),

            // Danh sách thuộc tính
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comparisonProperties.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                String key = comparisonProperties.keys.elementAt(index);
                String label = comparisonProperties[key]!['label'];
                IconData icon = comparisonProperties[key]!['icon'];
                String? value1 = _getStonePropertyValue(widget.firstStone, key);
                String? value2 = _getStonePropertyValue(widget.secondStone, key);
                bool areEqual = (value1 != null && value1.isNotEmpty) && (value1 == value2);

                return Container(
                  color: areEqual ? Colors.green.withOpacity(0.08) : null,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _PropertyCell(icon: icon, label: label, value: value1)),
                        VerticalDivider(color: Colors.grey.shade300, width: 1),
                        Expanded(child: _PropertyCell(icon: icon, label: label, value: value2)),
                      ],
                    ),
                  ),
                );
              },
            ),

            // FutureBuilder cho AI (không đổi)
            FutureBuilder<String>(
              future: _aiSummaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AiSummaryCard.loading();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return AiSummaryCard.error('Đã xảy ra lỗi khi tạo nhận xét: ${snapshot.error}');
                }
                if (snapshot.hasData) {
                  return AiSummaryCard(summary: snapshot.data!);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================================
  // >> SỬA ĐỔI 2: Cập nhật helper để lấy TẤT CẢ giá trị thuộc tính <<
  // =======================================================================
  String? _getStonePropertyValue(RockModels stone, String key) {
    switch (key) {
      case 'tenTiengViet':
        return stone.tenTiengViet;
      case 'loaiDa':
        return stone.loaiDa;
      case 'nhomDa':
        return stone.nhomDa;
      case 'nhanhDa':
        return stone.nhanhDa;
      case 'mauSac':
        return stone.mauSac;
      case 'doCung':
        return stone.doCung;
      case 'matDo':
        return stone.matDo;
      case 'kienTruc':
        return stone.kienTruc;
      case 'cauTao':
        return stone.cauTao;
      case 'thanhPhanHoaHoc':
        return stone.thanhPhanHoaHoc;
      case 'thanhPhanKhoangSan':
        return stone.thanhPhanKhoangSan;
      case 'dacDiem':
        return stone.dacDiem;
      case 'mieuTa':
        return stone.mieuTa;
      case 'congDung':
        return stone.congDung;
      case 'noiPhanBo':
        return stone.noiPhanBo;
      case 'motSoKhoangSanLienQuan':
        return stone.motSoKhoangSanLienQuan;
      // Xử lý đặc biệt cho các thuộc tính dạng List<String>
      case 'cauHoi':
        return stone.cauHoi.isNotEmpty ? stone.cauHoi.join('\n\n') : null;
      case 'traLoi':
        return stone.traLoi.isNotEmpty ? stone.traLoi.join('\n\n') : null;
      default:
        return null;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    // ... (Giữ nguyên code)
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
        decoration: BoxDecoration(color: const Color(0xFF303A53), borderRadius: BorderRadius.circular(20)),
        child: const Text("VS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

// Các widget con (_StoneHeader, _PropertyCell, AiSummaryCard) giữ nguyên như trước...

class AiSummaryCard extends StatelessWidget {
  final String? summary;
  final bool isLoading;
  final String? errorMessage;

  const AiSummaryCard({super.key, required this.summary})
      : isLoading = false,
        errorMessage = null;
  const AiSummaryCard.loading({super.key})
      : summary = null,
        isLoading = true,
        errorMessage = null;
  const AiSummaryCard.error(this.errorMessage, {super.key})
      : summary = null,
        isLoading = false;

  @override
  Widget build(BuildContext context) {
    // ... (Giữ nguyên code)
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text("Nhận Xét Từ AI", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF303A53))),
          ]),
          const Divider(height: 24),
          if (isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(children: [CircularProgressIndicator(), SizedBox(height: 16), Text("AI đang phân tích...", style: TextStyle(fontSize: 16))])))
          else if (errorMessage != null)
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center)))
          else if (summary != null)
            MarkdownBody(
              data: summary!,
              styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF303A53), height: 1.8),
                  listBullet: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
            )
        ],
      ),
    );
  }
}

class _StoneHeader extends StatelessWidget {
  final RockModels stone;
  const _StoneHeader({required this.stone});
  @override
  Widget build(BuildContext context) {
    // ... (Giữ nguyên code)
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
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
    );
  }
}

class _PropertyCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  const _PropertyCell({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    // ... (Giữ nguyên code)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
                child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700), overflow: TextOverflow.visible)),
          ]),
          const SizedBox(height: 6),
          Text(value ?? "—", style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }
}
