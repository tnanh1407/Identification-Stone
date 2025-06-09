import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rock_classifier/data/models/news_models.dart';
// QUAN TRỌNG: Vẫn import đúng package 'share_plus'
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends StatelessWidget {
  final NewsModels article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM, yyyy', 'vi_VN').format(article.createAt);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderImage(),
                  _buildContent(context, formattedDate),
                ],
              ),
            ),
          ),
          _buildTopAppBar(context),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    final imageUrl = article.fileDinhKem;
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: (imageUrl != null && imageUrl.isNotEmpty)
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(Icons.photo_size_select_actual_outlined, color: Colors.grey.shade500, size: 60),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkResponse(
            onTap: () => Navigator.of(context).pop(),
            radius: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String formattedDate) {
    final paragraphs = (article.noiDungBaiViet ?? '').split(RegExp(r'\n\s*\n'));

    return Container(
      transform: Matrix4.translationValues(0, -20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.tenBaiViet,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, size: 20, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.tacGia ?? 'Tác giả ẩn danh',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Đăng ngày $formattedDate',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          ...paragraphs.map((paragraph) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  paragraph,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 17, height: 1.7, color: Color(0xFF333333)),
                ),
              )),
          if (article.duongDan != null && article.duongDan!.isNotEmpty) _buildActionButtons(context, article.duongDan!),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String urlString) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Builder(
            builder: (BuildContext builderContext) {
              return ElevatedButton.icon(
                onPressed: () {
                  _shareArticle(builderContext, urlString);
                },
                icon: const Icon(Icons.share),
                label: const Text('Chia sẻ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              );
            },
          ),
          ElevatedButton.icon(
            onPressed: () => _launchURL(urlString),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Đọc thêm'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm helper để xử lý logic chia sẻ, đã cập nhật cho phiên bản share_plus mới nhất
  void _shareArticle(BuildContext context, String urlString) async {
    final box = context.findRenderObject() as RenderBox?;
    final String textToShare = 'Hãy xem bài viết thú vị này: ${article.tenBaiViet}\n\n$urlString';
    final String subject = 'Bài viết hay: ${article.tenBaiViet}';

    // Đã sửa lỗi: Dùng `Share.share` thay vì `Share.shareWithResult`
    // Hàm này giờ đây trả về kết quả và vẫn nhận tham số `sharePositionOrigin`
    await Share.share(
      textToShare,
      subject: subject,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $urlString');
    }
  }
}
