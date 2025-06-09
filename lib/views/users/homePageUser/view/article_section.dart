import 'package:flutter/material.dart';
import 'package:rock_classifier/data/models/news_models.dart';
import 'package:rock_classifier/data/services/firebase_news_service.dart';
import 'package:rock_classifier/views/users/news/article_detail_screen.dart';
import 'package:rock_classifier/views/users/news/all_article_section.dart';
// import 'package:stonelens/views/home/post_screen.dart'; // Bỏ comment khi bạn có màn hình chi tiết

class ArticleSection extends StatefulWidget {
  const ArticleSection({super.key});

  @override
  State<ArticleSection> createState() => _ArticleSectionState();
}

class _ArticleSectionState extends State<ArticleSection> {
  final FirebaseNewsService _newsService = FirebaseNewsService();
  late Future<List<NewsModels>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsService.fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    // SỬA: Không cần Padding ở đây nữa, sẽ áp dụng trực tiếp cho ListView
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8, top: 10, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Những bài viết về đá",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Điều hướng đến màn hình mới
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllArticlesScreen()),
                  );
                },
                child: const Text(
                  "Xem tất cả",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<NewsModels>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Hiển thị một placeholder có chiều cao cố định khi đang tải
              return const SizedBox(
                height: 220, // Chiều cao phải bằng chiều cao của ListView
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(height: 220, child: const Center(child: Text('Không thể tải bài viết.')));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox(height: 220, child: const Center(child: Text('Chưa có bài viết nào.')));
            }

            final articles = snapshot.data!;

            // SỬA: Bọc ListView.builder trong một SizedBox để có chiều cao cố định
            return SizedBox(
              height: 220, // Chiều cao của khu vực trượt ngang
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Đặt hướng trượt ngang
                padding: const EdgeInsets.symmetric(horizontal: 16), // Padding cho toàn bộ list
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  // Thêm padding bên phải cho mỗi item (trừ item cuối)
                  return Padding(
                    padding: EdgeInsets.only(right: index == articles.length - 1 ? 0 : 12),
                    // SỬA: Đặt chiều rộng cố định cho mỗi card
                    child: SizedBox(
                      width: 250, // Chiều rộng của mỗi card
                      child: ArticleCard(article: article),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

// WIDGET ARICLECARD VẪN GIỮ NGUYÊN
class ArticleCard extends StatefulWidget {
  final NewsModels article;

  const ArticleCard({super.key, required this.article});

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() => _scale = 1 - _controller.value);
      });
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    _navigateToDetail();
  }

  void _onTapCancel() => _controller.reverse();

  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: widget.article),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.article.fileDinhKem;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          },
                          // Trường hợp ảnh lỗi cũng có thể hiển thị icon
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey[400],
                                size: 50,
                              ),
                            );
                          },
                        )
                      // SỬA: Thay thế Image.asset bằng Container và Icon
                      : Container(
                          color: Colors.grey[200], // Màu nền xám nhẹ cho placeholder
                          alignment: Alignment.center, // Căn giữa icon
                          child: Icon(
                            Icons.image_not_supported_outlined, // Icon "không có ảnh"
                            color: Colors.grey[400], // Màu của icon
                            size: 50, // Kích thước của icon
                          ),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      widget.article.tenBaiViet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
