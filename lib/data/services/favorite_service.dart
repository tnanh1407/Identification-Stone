import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FavoriteService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper để lấy collection 'favorites' của user hiện tại một cách an toàn.
  // Không có gì thay đổi ở đây, nó đã rất tốt.
  CollectionReference? _getFavoritesCollection() {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return _firestore.collection('users').doc(user.uid).collection('favorites');
  }

  // THÊM MỚI: Hàm tiện ích để thêm hoặc xóa yêu thích trong một lần gọi.
  // Điều này giúp logic ở phía UI (trong các Widget) trở nên đơn giản hơn.
  ///
  /// - [rockId]: ID của loại đá cần thay đổi trạng thái.
  /// - [isCurrentlyFavorite]: Trạng thái yêu thích hiện tại của đá.
  Future<void> toggleFavorite(String rockId, bool isCurrentlyFavorite) async {
    if (isCurrentlyFavorite) {
      // Nếu đang là yêu thích, thì xóa nó đi
      await removeFavorite(rockId);
    } else {
      // Nếu chưa phải là yêu thích, thì thêm vào
      await addFavorite(rockId);
    }
  }

  /// Cung cấp một Stream để lắng nghe trạng thái yêu thích (true/false) của một loại đá (rock).
  ///
  /// - [rockId]: ID của loại đá cần kiểm tra.
  /// - Trả về `true` nếu đá được yêu thích, ngược lại trả về `false`.
  /// - Tự động trả về `false` nếu người dùng chưa đăng nhập.
  Stream<bool> rockFavoriteStatusStream(String rockId) {
    if (rockId.isEmpty) {
      return Stream.value(false);
    }

    final collection = _getFavoritesCollection();
    if (collection == null) {
      return Stream.value(false); // Người dùng chưa đăng nhập
    }

    return collection.doc(rockId).snapshots().map((snapshot) {
      return snapshot.exists;
    }).handleError((error) {
      debugPrint("Lỗi khi lắng nghe trạng thái yêu thích: $error");
      return false;
    });
  }

  /// Thêm một loại đá vào danh sách yêu thích của người dùng.
  ///
  /// - [rockId]: ID của loại đá cần thêm.
  /// - Nếu đã tồn tại, sẽ ghi đè nhưng không gây lỗi.
  Future<void> addFavorite(String rockId) async {
    final collection = _getFavoritesCollection();
    if (collection == null || rockId.isEmpty) {
      return;
    }

    try {
      // Dùng serverTimestamp để đảm bảo thời gian chính xác.
      await collection.doc(rockId).set({
        'favoritedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Lỗi khi thêm yêu thích: $e");
      rethrow;
    }
  }

  /// Xóa một loại đá khỏi danh sách yêu thích của người dùng.
  ///
  /// - [rockId]: ID của loại đá cần xóa.
  Future<void> removeFavorite(String rockId) async {
    final collection = _getFavoritesCollection();
    if (collection == null || rockId.isEmpty) {
      return;
    }

    try {
      await collection.doc(rockId).delete();
    } catch (e) {
      debugPrint("Lỗi khi xóa yêu thích: $e");
      rethrow;
    }
  }

  /// Cung cấp một Stream chứa danh sách các `rockId` đã được yêu thích.
  ///
  /// - Rất hữu ích để lấy tất cả các mục yêu thích và hiển thị chúng.
  /// - Tự động trả về danh sách rỗng nếu người dùng chưa đăng nhập.
  Stream<List<String>> getFavoriteRockIdsStream() {
    final collection = _getFavoritesCollection();
    if (collection == null) {
      return Stream.value([]);
    }

    // Sắp xếp theo thời gian thêm để danh sách luôn ổn định
    return collection.orderBy('favoritedAt', descending: true).snapshots().map((snapshot) {
      // Lấy ID của mỗi document, chính là rockId.
      return snapshot.docs.map((doc) => doc.id).toList();
    }).handleError((error) {
      debugPrint("Lỗi khi lấy danh sách ID yêu thích: $error");
      return <String>[];
    });
  }
}
