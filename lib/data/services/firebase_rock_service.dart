// lib/data/services/firebase_rock_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:rock_classifier/data/models/rock_models.dart';

class FirebaseRockService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String collectionName = '_rocks';

  Future<List<RockModels>> fetchAllRocks() async {
    final snapshot = await _db.collection(collectionName).orderBy('tenDa').get();
    return snapshot.docs.map((doc) => RockModels.fromJson({'uid': doc.id, ...doc.data()})).toList();
  }

  Future<String> addRock(RockModels rock) async {
    final docRef = _db.collection(collectionName).doc();
    await docRef.set(rock.copyWith(uid: docRef.id).toJson());
    return docRef.id; // Trả về ID của document mới tạo
  }

  Future<void> deleteRock(RockModels rock) async {
    // Xóa tất cả hình ảnh liên quan trong Storage
    for (var imageUrl in rock.hinhAnh) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (e) {
        print("Không thể xóa ảnh $imageUrl: $e");
      }
    }
    await _db.collection(collectionName).doc(rock.uid).delete();
  }

  Future<void> updateRock(RockModels rock) async {
    await _db.collection(collectionName).doc(rock.uid).update(rock.toJson());
  }

  // Hàm upload ảnh, sử dụng `tenDa` làm tên thư mục
  Future<String> uploadImage(File imageFile, String rockName) async {
    // Làm sạch tên đá để dùng làm tên thư mục một cách an toàn
    // Ví dụ: "Đá Granit / Phấn" -> "a_Granit___Ph_n"
    final safeFolderName = rockName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').replaceAll('__', '_');

    // Đặt tên file ngẫu nhiên để tránh trùng lặp
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${basename(imageFile.path)}';

    // Sử dụng cấu trúc thư mục bạn mong muốn
    final ref = _storage.ref().child('image_rock/$safeFolderName/$fileName');

    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }
}
