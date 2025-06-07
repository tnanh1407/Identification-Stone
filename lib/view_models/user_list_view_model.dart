import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rock_classifier/data/models/user_models.dart';
import 'package:rock_classifier/data/services/firebase_service.dart';
import 'package:rock_classifier/views/admin/users/view/user_data_management.dart';
import 'package:image_picker/image_picker.dart';

class UserListViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();

  List<UserModels> _originalUsers = []; // Biến để lưu danh sách gốc
  List<UserModels> _users = [];
  List<UserModels> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setUpdating(bool value) {
    _isUpdating = value;
    notifyListeners();
  }

  // --- CÁC HÀM LẤY DỮ LIỆU ---

  Future<void> fetchUser() async {
    _setLoading(true);
    try {
      _originalUsers = await _firebaseService.getUsers();
      _users = List.from(_originalUsers); // Sao chép danh sách gốc
    } catch (e) {
      debugPrint("Lỗi khi fetch user: $e");
      _originalUsers = [];
      _users = [];
    } finally {
      _setLoading(false);
    }
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      _users = List.from(_originalUsers); // Nếu query rỗng, trả về danh sách gốc
    } else {
      final lowerCaseQuery = query.toLowerCase();
      _users = _originalUsers.where((user) {
        return (user.fullName?.toLowerCase().contains(lowerCaseQuery) ?? false) || user.email.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }
    notifyListeners();
  }

  void sortUsers(SortOption option) {
    switch (option) {
      case SortOption.createdAt:
        _users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.role:
        _users.sort((a, b) => a.role.compareTo(b.role));
        break;
      case SortOption.name:
        _users.sort((a, b) => (a.fullName ?? a.email).toLowerCase().compareTo((b.fullName ?? b.email).toLowerCase()));
        break;
    }
    notifyListeners();
  }

  // --- CÁC HÀM THÊM/SỬA/XÓA (ĐÃ GỘP LOGIC) ---

  Future<void> addUser(UserModels user, File? image) async {
    _setUpdating(true);
    try {
      // Logic tạo UserCredential được chuyển vào đây
      UserCredential result = await _firebaseService.createUserWithEmailAndPassword(
        email: user.email,
        password: 'defaultPassword123', // Mật khẩu mặc định, hoặc lấy từ UI nếu có
      );

      final newUser = user.copyWith(uid: result.user!.uid); // Cập nhật UID từ Firebase Auth

      String? avatarUrl;
      if (image != null) {
        avatarUrl = await _firebaseService.uploadAvatar(image, newUser.uid);
      }

      final userWithAvatar = newUser.copyWith(avatar: avatarUrl);
      await _firebaseService.addUser(userWithAvatar); // Hàm này chỉ cần set data vào Firestore

      await fetchUser(); // Tải lại danh sách sau khi thêm
    } catch (e) {
      debugPrint("Lỗi khi thêm user: $e");
      rethrow; // Ném lại lỗi để UI có thể bắt và hiển thị
    } finally {
      _setUpdating(false);
    }
  }

  Future<void> updateUserWithOptionalImage(UserModels user, File? image) async {
    _setUpdating(true);
    try {
      UserModels userToUpdate = user; // Bắt đầu với user đã chứa các thay đổi từ UI

      if (image != null) {
        // Nếu có ảnh mới, upload và cập nhật avatarUrl vào đối tượng
        final newAvatarUrl = await _firebaseService.uploadAvatar(image, user.uid);
        userToUpdate = userToUpdate.copyWith(avatar: newAvatarUrl);
      }

      // Bây giờ userToUpdate đã chứa TẤT CẢ các thay đổi (text và ảnh mới nếu có)
      await _firebaseService.updateUser(userToUpdate);

      await fetchUser(); // Tải lại danh sách để UI cập nhật
    } catch (e) {
      debugPrint("Lỗi khi cập nhật user: $e");
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  Future<void> deleteUser(UserModels user) async {
    _setUpdating(true);
    try {
      if (user.avatar != null) {
        try {
          // FirebaseService nên có hàm xóa avatar
          await _firebaseService.deleteAvatar(user.avatar!);
        } catch (e) {
          debugPrint("Không thể xóa avatar cũ: $e");
        }
      }
      await _firebaseService.deleteUser(user.uid);

      await fetchUser(); // Tải lại danh sách sau khi xóa
    } catch (e) {
      debugPrint("Lỗi khi xóa user: $e");
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // --- HÀM HELPER CHO HÌNH ẢNH ---

  Future<File?> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
