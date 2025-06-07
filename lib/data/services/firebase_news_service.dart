import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:rock_classifier/data/models/news_models.dart';

class FirebaseNewsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String collectionName = '_news';

  Future<List<NewsModels>> fetchNews() async {
    final snapshot = await _db.collection(collectionName).orderBy('createAt', descending: true).get();
    return snapshot.docs.map((doc) => NewsModels.fromJson(doc.data(), doc.id)).toList();
  }

  Future<void> updateNews(NewsModels news) async {
    await _db.collection(collectionName).doc(news.uid).update(news.toJson());
  }

  Future<void> deleteNews(NewsModels news) async {
    // Xóa file đính kèm nếu có
    if (news.fileDinhKem != null && news.fileDinhKem!.isNotEmpty) {
      try {
        await _storage.refFromURL(news.fileDinhKem!).delete();
      } catch (e) {
        print("Không thể xóa file đính kèm: $e");
      }
    }
    await _db.collection(collectionName).doc(news.uid).delete();
  }

  Future<String> addNews(NewsModels news) async {
    final docRef = await _db.collection(collectionName).add(news.toJson());
    return docRef.id; // Trả về ID của document mới
  }

  // Hàm upload file đính kèm
  Future<String> uploadAttachment(File file, String newsId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${basename(file.path)}';
    final ref = _storage.ref().child('$collectionName/$newsId/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
