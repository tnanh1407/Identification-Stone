import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart'; // Cần import để dùng trong try-catch
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rock_classifier/data/models/news_models.dart';
import 'package:rock_classifier/data/models/user_models.dart';
import 'package:rock_classifier/data/services/firebase_news_service.dart';

class NewsViewModel with ChangeNotifier {
  final FirebaseNewsService _service = FirebaseNewsService();
  final ImagePicker _picker = ImagePicker();

  List<NewsModels> _originalNews = [];
  List<NewsModels> _news = [];
  List<NewsModels> get news => _news;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  Future<void> fetchNews() async {
    // SỬA: Thay thế _setLoading(true)
    _isLoading = true;
    notifyListeners();

    try {
      _originalNews = await _service.fetchNews();
      _news = List.from(_originalNews);
    } catch (e) {
      debugPrint("Lỗi fetchNews: $e");
    } finally {
      // SỬA: Thay thế _setLoading(false)
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNews(NewsModels news, UserModels currentUser, {File? attachment}) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final author = currentUser.fullName ?? currentUser.email;
      var newsWithAuthor = news.copyWith(tacGia: author);

      final newId = await _service.addNews(newsWithAuthor);

      if (attachment != null) {
        final fileUrl = await _service.uploadAttachment(attachment, newId);
        newsWithAuthor = newsWithAuthor.copyWith(uid: newId, fileDinhKem: fileUrl);
        await _service.updateNews(newsWithAuthor);
      }

      await fetchNews();
    } catch (e) {
      debugPrint("Lỗi addNews: $e");
      rethrow;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> updateNews(NewsModels news, {File? newAttachment}) async {
    // SỬA: Thay thế _setUpdating(true)
    _isUpdating = true;
    notifyListeners();

    try {
      var newsToUpdate = news;
      if (newAttachment != null) {
        // SỬA: Chuyển logic xóa file cũ vào service nếu có thể,
        // nhưng giữ ở đây cũng tạm chấp nhận được.
        if (news.fileDinhKem != null && news.fileDinhKem!.isNotEmpty) {
          try {
            await FirebaseStorage.instance.refFromURL(news.fileDinhKem!).delete();
          } catch (e) {
            debugPrint("Không thể xóa file cũ: $e");
          }
        }
        final fileUrl = await _service.uploadAttachment(newAttachment, news.uid);
        newsToUpdate = news.copyWith(fileDinhKem: fileUrl);
      }

      await _service.updateNews(newsToUpdate);
      await fetchNews();
    } catch (e) {
      debugPrint("Lỗi updateNews: $e");
      rethrow;
    } finally {
      // SỬA: Thay thế _setUpdating(false)
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> deleteNews(NewsModels news) async {
    // SỬA: Thay thế _setUpdating(true)
    _isUpdating = true;
    notifyListeners();

    try {
      await _service.deleteNews(news);
      await fetchNews();
    } catch (e) {
      debugPrint("Lỗi deleteNews: $e");
      rethrow;
    } finally {
      // SỬA: Thay thế _setUpdating(false)
      _isUpdating = false;
      notifyListeners();
    }
  }

  void searchNews(String query) {
    if (query.isEmpty) {
      _news = List.from(_originalNews);
    } else {
      final lowerCaseQuery = query.toLowerCase();
      _news = _originalNews.where((item) {
        return item.tenBaiViet.toLowerCase().contains(lowerCaseQuery) || (item.chuDe?.toLowerCase().contains(lowerCaseQuery) ?? false);
      }).toList();
    }
    notifyListeners();
  }

  void sortByCreateAt({bool ascending = false}) {
    if (ascending) {
      _news.sort((a, b) => a.createAt.compareTo(b.createAt));
    } else {
      _news.sort((a, b) => b.createAt.compareTo(a.createAt));
    }
    notifyListeners();
  }

  Future<File?> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
