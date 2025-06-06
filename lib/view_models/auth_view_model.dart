import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rock_classifier/data/models/user_models.dart';
import 'package:rock_classifier/data/services/firebase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  UserModels? _currentUser;
  UserModels? get currentUser => _currentUser;

  String? _currentUserRole;
  String? get currentUserRole => _currentUserRole;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<UserModels?> getCurrentUser() async {
    final firebaseUser = _firebaseService.auth.currentUser;
    if (firebaseUser != null) {
      return await _firebaseService.getUserById(firebaseUser.uid);
    }
    return null;
  }

  AuthViewModel() {
    _firebaseService.auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        _currentUser = await _firebaseService.getUserById(firebaseUser.uid);
        _currentUserRole = _currentUser?.role;
      } else {
        _currentUser = null;
        _currentUserRole = null;
      }
      notifyListeners();
    });
  }

  // Đăng nhập tài khoản
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Thông báo cho UI biết quá trình
    try {
      await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = _firebaseService.auth.currentUser;
      if (firebaseUser != null) {
        _currentUser = await _firebaseService.getUserById(firebaseUser.uid);
        _currentUserRole = _currentUser?.role; //Lấy role trực tiếp

        if (_currentUserRole == null) {
          _errorMessage = 'Không tìm thấy vai trò của người dùng';
          return false;
        }

        _errorMessage = null;
        return true;
      } else {
        _errorMessage = 'Không thể lấy thông tin người dùng';
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseAuthError(e);
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi không xác định: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Đăng kí tài khoản
  Future<bool> signUp(String email, String password, String password2) async {
    if (password != password2) {
      _errorMessage = "Mật khẩu không khớp !";
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      UserCredential result = await _firebaseService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        UserModels newUser = UserModels(
          uid: user.uid,
          fullName: null,
          address: null,
          email: email,
          avatar: null,
          role: "User",
          createdAt: DateTime.now(),
        );
        await _firebaseService.firestore.collection('users').doc(user.uid).set(newUser.toJson());
        _currentUser = newUser;
        _currentUserRole = newUser.role;
        return true;
      }
      _errorMessage = "Không thể tạo tài khoản ";
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseAuthError(e);
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi không xác định: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _firebaseService.auth.signOut();
    _currentUser = null;
    _currentUserRole = null;
    notifyListeners();
  }

  // Cập nhật ngườu dùng
  Future<void> updateUser(UserModels user) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firebaseService.updateUser(user);
      _currentUser = user;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật thông tin: $e';
    } finally {
      _isLoading = false;
      notifyListeners(); // Cập nhật lại sau khi hoàn tất
    }
  }

  // Tải ảnh lên ứng dụng
  Future<String?> uploadAvatar(File image) async {
    try {
      _isLoading = true;
      notifyListeners();

      final uid = _firebaseService.auth.currentUser?.uid;
      // Kiểm tra ui người dùng
      if (uid == null) {
        _errorMessage = 'Không tìm thấy người dùng !';
        return null;
      }

      final url = await _firebaseService.uploadAvatar(image, uid);
      if (url != null && _currentUser != null) {
        await updateUser(_currentUser!.copyWith(avatar: url));
      }
      return url;
    } catch (e) {
      _errorMessage = 'Lỗi tải ảnh : $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'weak-password':
        return 'Mật khẩu quá yếu (ít nhất 6 ký tự)';
      case 'operation-not-allowed':
        return 'Chức năng đăng ký bị vô hiệu hóa';
      case 'network-request-failed':
        return 'Không có kết nối mạng';
      case 'user-not-found':
      case 'wrong-password':
        return 'Email hoặc mật khẩu không đúng';
      default:
        return 'Đã xảy ra lỗi: ${e.message}';
    }
  }

  // Cập nhật password người dùng
  Future<String?> updatePassword(String oldPassword, String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();
      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        return _errorMessage;
      }
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      _errorMessage = null;
      return null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseAuthError(e);
      return _errorMessage;
    } catch (e) {
      _errorMessage = 'Lỗi không xác định: $e';
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserInfo({
    required String fullName,
    required String address,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      final firebaseUser = _firebaseService.auth.currentUser;
      if (firebaseUser == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        return false;
      }

      // Cập nhật thông tin người dùng trong Firestore
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(
          fullName: fullName.isEmpty ? null : fullName,
          address: address.isEmpty ? null : address,
        );
        await _firebaseService.updateUser(updatedUser);
        _currentUser = updatedUser;
      }

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật thông tin: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isAdmin() => _currentUserRole == 'Admin';
  bool isSuperUser() => _currentUserRole == 'Super-User';
  bool isUser() => _currentUserRole == 'User';
}
