import 'package:flutter/material.dart';
import 'package:rock_classifier/data/models/news_models.dart';
import 'package:rock_classifier/data/services/firebase_news_service.dart';
import 'package:rock_classifier/views/users/news/article_detail_screen.dart';

class AllArticlesScreen extends StatefulWidget {
  const AllArticlesScreen({super.key});

  @override
  State<AllArticlesScreen> createState() => _AllArticlesScreenState();
}

class _AllArticlesScreenState extends State<AllArticlesScreen> with TickerProviderStateMixin {
  final FirebaseNewsService _newsService = FirebaseNewsService();
  late Future<List<NewsModels>> _allArticlesFuture;

  TabController? _tabController;
  Map<String, List<NewsModels>> _groupedArticles = {};
  List<String> _tabs = [];

  @override
  void initState() {
    super.initState();
    _allArticlesFuture = _newsService.fetchNews();
    _groupArticles();
  }

  void _groupArticles() async {
    final articles = await _allArticlesFuture;
    final tempGroup = <String, List<NewsModels>>{};

    for (var article in articles) {
      final chuDe = article.chuDe?.trim() ?? '';
      final key = chuDe.isNotEmpty ? chuDe : 'Khác';

      if (tempGroup.containsKey(key)) {
        tempGroup[key]!.add(article);
      } else {
        tempGroup[key] = [article];
      }
    }

    // Logic sắp xếp các tab
    final sortedTabs = tempGroup.keys.toList();
    sortedTabs.sort();
    if (sortedTabs.contains('Khác')) {
      sortedTabs.remove('Khác');
      sortedTabs.add('Khác');
    }

    setState(() {
      _groupedArticles = tempGroup;
      _tabs = sortedTabs;
      _tabController = TabController(length: _tabs.length, vsync: this);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả bài viết'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        bottom: _tabController == null
            ? const PreferredSize(
                preferredSize: Size.fromHeight(48.0),
                child: Center(child: LinearProgressIndicator()),
              )
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.blue,
                tabs: _tabs.map((tabName) => Tab(text: tabName)).toList(),
              ),
      ),
      body: _tabController == null
          ? const Center(child: CircularProgressIndicator()) // Hiển thị loading khi chưa có tab
          : TabBarView(
              controller: _tabController,
              children: _tabs.map((tabName) {
                final articlesInTab = _groupedArticles[tabName]!;
                return ArticleListView(articles: articlesInTab);
              }).toList(),
            ),
    );
  }
}

// Widget phụ để hiển thị danh sách bài viết trong một tab
class ArticleListView extends StatelessWidget {
  final List<NewsModels> articles;
  const ArticleListView({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const Center(child: Text('Không có bài viết trong chủ đề này.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return ArticleListItem(article: articles[index]);
      },
    );
  }
}

// Widget phụ cho mỗi mục bài viết (Card)
class ArticleListItem extends StatelessWidget {
  final NewsModels article;
  const ArticleListItem({super.key, required this.article});

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
    );
  }

  // Widget phụ để tạo placeholder, tránh lặp code
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey[400],
          size: 50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.fileDinhKem;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetail(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Luôn hiển thị khu vực ảnh
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    // Nếu có ảnh -> hiển thị Image.network
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                      )
                    // Nếu không có ảnh -> hiển thị placeholder
                    : _buildImagePlaceholder(),
              ),
            ),
            // Phần text bên dưới
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.tenBaiViet,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        article.tacGia ?? 'Không rõ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        // Định dạng lại ngày tháng cho thân thiện
                        "${article.createAt.day}/${article.createAt.month}/${article.createAt.year}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
