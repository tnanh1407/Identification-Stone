import 'package:flutter/material.dart';
import 'package:rock_classifier/data/models/rock_models.dart';
// import 'package:rock_classifier/views/users/rock/RockImageDialog_result.dart'; // Đảm bảo đường dẫn này đúng

class StoneInfoWidget extends StatelessWidget {
  final RockModels rock;

  const StoneInfoWidget({
    required this.rock,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> hinhAnh = rock.hinhAnh;

    // Nếu không có thông tin và chỉ có 1 ảnh (ảnh chính), không hiển thị widget này
    final bool hasInfo = (rock.thanhPhanHoaHoc?.isNotEmpty ?? false) || (rock.doCung?.isNotEmpty ?? false) || (rock.mauSac?.isNotEmpty ?? false);

    if (!hasInfo && hinhAnh.length <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), // Tăng padding ngang một chút
        decoration: BoxDecoration(
          color: const Color(0xFF303A53),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cột ảnh (chỉ hiển thị nếu có nhiều hơn 1 ảnh)
            if (hinhAnh.length > 1)
              Expanded(
                flex: 2, // Cột ảnh chiếm 2 phần
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hinhAnh.length >= 3) _buildImageRow(context, hinhAnh[1], hinhAnh[2]),
                    if (hinhAnh.length >= 5) const SizedBox(height: 8),
                    if (hinhAnh.length >= 5) _buildImageRow(context, hinhAnh[3], hinhAnh[4]),
                  ],
                ),
              ),

            if (hinhAnh.length > 1) const SizedBox(width: 16), // Tăng khoảng cách

            // Cột thông tin
            Expanded(
              flex: 3, // Cột text chiếm 3 phần
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoText('Công thức hóa học', rock.thanhPhanHoaHoc),
                  _buildInfoText('Độ cứng', rock.doCung),
                  _buildInfoText('Màu sắc', rock.mauSac),
                ]
                    .where((widget) => widget is! SizedBox)
                    .toList() // Lọc bỏ các SizedBox trống
                    .expand((widget) => [widget, const SizedBox(height: 16)])
                    .toList()
                  ..removeLast(), // Thêm khoảng cách đều
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    // showDialog(context: context, builder: (context) => RockImageDialog(imagePath: imagePath));
  }

  // THAY ĐỔI: Bọc mỗi _buildImage trong Expanded
  Widget _buildImageRow(BuildContext context, String image1, String image2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: _buildImage(context, image1)),
        const SizedBox(width: 8),
        Expanded(child: _buildImage(context, image2)),
      ],
    );
  }

  // THAY ĐỔI: Bỏ width/height cố định, dùng AspectRatio
  Widget _buildImage(BuildContext context, String imagePath) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, imagePath),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        // AspectRatio sẽ làm cho ảnh luôn là hình vuông, lấp đầy chiều rộng linh hoạt từ Expanded
        child: AspectRatio(
          aspectRatio: 1.0, // Tỷ lệ 1:1 (vuông)
          child: Image.network(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade700,
              child: const Icon(Icons.broken_image, color: Colors.grey, size: 30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, // Tăng kích thước font một chút
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 5),
        Text(value,
            // Bỏ maxLines để text có thể xuống dòng tự do trong không gian của nó
            // maxLines: 2,
            // overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 15, // Tăng kích thước font một chút
                color: Color(0xFFE57C3B),
                height: 1.4)),
      ],
    );
  }
}
