// lib/widgets/home/popular_rocks_section.dart (Tên file giả định)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/view_models/rock_view_model.dart';

class PopularRocksSection extends StatelessWidget {
  const PopularRocksSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RockViewModel>(
      builder: (context, rockViewModel, child) {
        // SỬA: Lấy dữ liệu từ getter đã được sửa trong ViewModel
        final popularRocks = rockViewModel.popularRocksByLoaiDa;

        // Chỉ hiển thị section này nếu có dữ liệu
        if (popularRocks.isEmpty && !rockViewModel.isLoading) {
          return const SizedBox.shrink(); // Không hiển thị gì nếu rỗng
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                "Những loại đá phổ biến",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            if (rockViewModel.isLoading && popularRocks.isEmpty)
              const SizedBox(
                height: 125, // Chiều cao cố định để không làm layout nhảy
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SizedBox(
                height: 125, // Chiều cao của khu vực trượt ngang
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularRocks.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final rock = popularRocks[index];
                    final name = rock.loaiDa ?? 'N/A';
                    final imageUrl = (rock.hinhAnh.isNotEmpty) ? rock.hinhAnh[0] : null;

                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: PopularRockCard(
                        name: name,
                        imageUrl: imageUrl,
                        onTap: () {
                          // TODO: Xử lý khi nhấn vào một loại đá phổ biến
                          // Ví dụ: Điều hướng đến màn hình hiển thị tất cả đá có cùng `loaiDa`
                          print("Đã nhấn vào: $name");
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

// SỬA: Cải tiến RockCard thành PopularRockCard
class PopularRockCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final VoidCallback onTap;

  const PopularRockCard({
    Key? key,
    required this.name,
    this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90, // Chiều rộng cố định cho mỗi mục
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sử dụng CircleAvatar cho ảnh tròn
            CircleAvatar(
              radius: 42, // Kích thước của vòng tròn
              backgroundColor: Colors.grey.shade200,
              // Ảnh nền của CircleAvatar
              backgroundImage: (imageUrl != null) ? NetworkImage(imageUrl!) : null,
              // Widget con chỉ hiển thị khi không có ảnh nền
              child: (imageUrl == null) ? Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 30) : null,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
