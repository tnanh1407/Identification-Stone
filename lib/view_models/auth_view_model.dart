import 'dart:io';

import 'package:easy_localization/easy_localization.dart'; // THÊM DÒNG NÀY
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

  Future<void> _loadUserData(String uid) async {
    try {
      _currentUser = await _firebaseService.getUserById(uid);
      _currentUserRole = _currentUser?.role;
    } catch (e) {
      // Xử lý trường hợp không lấy được user data, ví dụ user bị xóa trong DB
      _currentUser = null;
      _currentUserRole = null;
      // THAY ĐỔI: Sử dụng key từ file JSON
      _errorMessage = 'auth.errors.user_data_load_failed'.tr();
    }
  }

  AuthViewModel() {
    _firebaseService.auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid); // Tái sử dụng hàm _loadUserData
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
    notifyListeners();
    try {
      await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = _firebaseService.auth.currentUser;
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid); // Tải dữ liệu người dùng

        if (_currentUserRole == null) {
          // THAY ĐỔI: Sử dụng key từ file JSON
          _errorMessage = 'auth.errors.user_role_not_found'.tr();
          return false;
        }

        _errorMessage = null;
        return true;
      } else {
        // THAY ĐỔI: Sử dụng key từ file JSON
        _errorMessage = 'auth.errors.user_info_fetch_failed'.tr();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseAuthError(e);
      return false;
    } catch (e) {
      // THAY ĐỔI: Sử dụng key từ file JSON với tham số
      _errorMessage = 'common.error_unknown'.tr(namedArgs: {'error': e.toString()});
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password, String password2, {String? fullName}) async {
    if (password != password2) {
      // THAY ĐỔI: Sử dụng key từ file JSON
      _errorMessage = 'auth.errors.password_mismatch'.tr();
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
          fullName: (fullName != null && fullName.isNotEmpty) ? fullName : null,
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
      // THAY ĐỔI: Sử dụng key từ file JSON
      _errorMessage = 'auth.errors.account_creation_failed'.tr();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseAuthError(e);
      return false;
    } catch (e) {
      // THAY ĐỔI: Sử dụng key từ file JSON với tham số
      _errorMessage = 'common.error_unknown'.tr(namedArgs: {'error': e.toString()});
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _firebaseService.auth.signOut();
    _currentUser = null;
    _currentUserRole = null;
    notifyListeners();
  }

  Future<bool> updateUser(UserModels user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _firebaseService.updateUser(user);
      _currentUser = user;
      return true;
    } catch (e) {
      // THAY ĐỔI: Sử dụng key từ file JSON với tham số
      _errorMessage = 'common.error_update_failed'.tr(namedArgs: {'error': e.toString()});
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadAvatar(File image) async {
    final uid = _firebaseService.auth.currentUser?.uid;
    if (uid == null || _currentUser == null) {
      // THAY ĐỔI: Sử dụng key từ file JSON
      _errorMessage = 'auth.errors.user_not_found'.tr();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = await _firebaseService.uploadAvatar(image, uid);
      if (url != null) {
        return await updateUser(_currentUser!.copyWith(avatar: url));
      }
      // THAY ĐỔI: Sử dụng key từ file JSON
      _errorMessage = 'auth.errors.avatar_url_failed'.tr();
      return false;
    } catch (e) {
      // THAY ĐỔI: Sử dụng key từ file JSON với tham số
      _errorMessage = 'common.error_upload_failed'.tr(namedArgs: {'error': e.toString()});
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    // THAY ĐỔI: Toàn bộ hàm này trả về các key đã được dịch
    switch (e.code) {
      case 'invalid-email':
        return 'auth.errors.email_invalid'.tr();
      case 'email-already-in-use':
        return 'auth.errors.email_in_use'.tr();
      case 'weak-password':
        return 'auth.errors.password_length'.tr();
      case 'operation-not-allowed':
        return 'auth.errors.operation_not_allowed'.tr();
      case 'network-request-failed':
        return 'common.error_network'.tr();
      case 'user-not-found':
      case 'wrong-password':
        return 'auth.errors.wrong_password'.tr();
      default:
        return 'common.error_with_message'.tr(namedArgs: {'message': e.message ?? 'N/A'});
    }
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null || user.email == null) {
        // THAY ĐỔI: Sử dụng key từ file JSON
        _errorMessage = 'auth.errors.reauth_failed'.tr();
        return false;
      }
      final cred = EmailAuthProvider.credential(email: user.email!, password: oldPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseAuthError(e);
      return false;
    } catch (e) {
      // THAY ĐỔI: Sử dụng key từ file JSON với tham số
      _errorMessage = 'common.error_unknown'.tr(namedArgs: {'error': e.toString()});
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Gửi email đặt lại mật khẩu
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
      return true; // Gửi thành công
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseAuthError(e); // Tái sử dụng hàm xử lý lỗi
      return false;
    } catch (e) {
      _errorMessage = 'common.error_unknown'.tr(namedArgs: {'error': e.toString()});
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
