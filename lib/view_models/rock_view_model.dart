// lib/view_models/rock_view_model.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rock_classifier/data/models/rock_models.dart';
import 'package:rock_classifier/data/services/firebase_rock_service.dart';

enum RockSortOption { tenDa, loaiDa, nhomDa }

class RockViewModel with ChangeNotifier {
  final FirebaseRockService _service = FirebaseRockService();
  final ImagePicker _picker = ImagePicker();
  RockSortOption _currentSortOption = RockSortOption.tenDa; // Mặc định sắp xếp theo tên
  RockSortOption get currentSortOption => _currentSortOption;

  List<RockModels> _originalRocks = [];
  // Danh sách này sẽ được sử dụng bởi màn hình "Xem tất cả"
  List<RockModels> _displayRocks = [];
  List<RockModels> get rocks => _displayRocks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    Future.microtask(() => notifyListeners());
  }

  void _setUpdating(bool value) {
    if (_isUpdating == value) return;
    _isUpdating = value;
    Future.microtask(() => notifyListeners());
  }

  Future<void> fetchRocks() async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      _originalRocks = await _service.fetchAllRocks();
      // Luôn đảm bảo _displayRocks được khởi tạo từ danh sách gốc
      _displayRocks = List.from(_originalRocks);
    } catch (e) {
      debugPrint("Lỗi fetchRocks: $e");
      _originalRocks = [];
      _displayRocks = [];
    } finally {
      _setLoading(false);
    }
  }

  // Các hàm CRUD (add, update, delete) sẽ gọi fetchRocks() ở cuối,
  // tự động reset lại _displayRocks về trạng thái gốc.
  Future<void> addRock(RockModels rock, List<File> images) async {
    _setUpdating(true);
    try {
      if (rock.tenDa == null || rock.tenDa!.isEmpty) {
        throw Exception('Tên đá không được để trống khi thêm ảnh.');
      }

      List<String> imageUrls = [];
      for (var imageFile in images) {
        final url = await _service.uploadImage(imageFile, rock.tenDa!);
        imageUrls.add(url);
      }

      final rockWithImages = rock.copyWith(hinhAnh: imageUrls);
      await _service.addRock(rockWithImages);
      await fetchRocks();
    } catch (e) {
      debugPrint("Lỗi addRock: $e");
      _setUpdating(false);
      rethrow;
    }
  }

  Future<void> updateRock(RockModels rock, List<File> newImages) async {
    _setUpdating(true);
    try {
      if (rock.tenDa == null || rock.tenDa!.isEmpty) {
        throw Exception('Tên đá không được để trống khi thêm ảnh.');
      }
      List<String> finalImageUrls = List.from(rock.hinhAnh);
      for (var imageFile in newImages) {
        final url = await _service.uploadImage(imageFile, rock.tenDa!);
        finalImageUrls.add(url);
      }
      final rockToUpdate = rock.copyWith(hinhAnh: finalImageUrls);
      await _service.updateRock(rockToUpdate);
      await fetchRocks();
    } catch (e) {
      debugPrint("Lỗi updateRock: $e");
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  Future<void> deleteRock(RockModels rock) async {
    _setUpdating(true);
    try {
      await _service.deleteRock(rock);
      await fetchRocks();
    } catch (e) {
      debugPrint("Lỗi deleteRock: $e");
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  /// HÀM TÌM KIẾM CHO MÀN HÌNH "XEM TẤT CẢ"
  /// Thao tác trực tiếp trên _displayRocks
  void searchAllRocks(String query) {
    if (query.isEmpty) {
      // Nếu không tìm kiếm, hiển thị danh sách gốc
      _displayRocks = List.from(_originalRocks);
    } else {
      final lowerCaseQuery = query.toLowerCase();
      // Luôn tìm kiếm từ danh sách gốc để đảm bảo kết quả đúng
      _displayRocks = _originalRocks.where((rock) {
        return (rock.tenDa?.toLowerCase().contains(lowerCaseQuery) ?? false) || (rock.loaiDa?.toLowerCase().contains(lowerCaseQuery) ?? false);
      }).toList();
    }
    notifyListeners();
  }

  /// HÀM SẮP XẾP CHO MÀN HÌNH "XEM TẤT CẢ"
  /// Thao tác trực tiếp trên _displayRocks
  void sortAllRocks(RockSortOption option) {
    // SỬA: Cập nhật trạng thái sắp xếp hiện tại
    _currentSortOption = option;

    switch (option) {
      case RockSortOption.tenDa:
        _displayRocks.sort((a, b) => (a.tenDa ?? '').compareTo(b.tenDa ?? ''));
        break;
      case RockSortOption.loaiDa:
        _displayRocks.sort((a, b) => (a.loaiDa ?? '').compareTo(b.loaiDa ?? ''));
        break;
      case RockSortOption.nhomDa:
        _displayRocks.sort((a, b) => (a.nhomDa ?? '').compareTo(b.nhomDa ?? ''));
        break;
    }
    notifyListeners();
  }

  /// HÀM RESET, ĐẢM BẢO MÀN HÌNH "XEM TẤT CẢ" LUÔN HIỂN THỊ ĐẦY ĐỦ
  void resetAllFilters() {
    _displayRocks = List.from(_originalRocks);
    notifyListeners();
  }

  // Getter lấy category vẫn giữ nguyên, hoạt động trên danh sách gốc
  List<String> get uniqueNhanhDaCategories {
    if (_originalRocks.isEmpty) return ['Tất cả'];
    final seenNhanhDa = <String>{};
    for (var rock in _originalRocks) {
      if (rock.nhanhDa != null && rock.nhanhDa!.trim().isNotEmpty) {
        seenNhanhDa.add(rock.nhanhDa!.trim());
      }
    }
    final sortedList = seenNhanhDa.toList()..sort();
    return ['Tất cả', ...sortedList];
  }

  List<RockModels> get popularRocksByLoaiDa {
    // Nếu chưa có dữ liệu, trả về danh sách rỗng
    if (_originalRocks.isEmpty) return [];

    final seenLoaiDa = <String>{};
    final uniqueList = <RockModels>[];

    // QUAN TRỌNG: Luôn lặp qua `_originalRocks` để không bị ảnh hưởng bởi các bộ lọc khác
    for (var rock in _originalRocks) {
      if (rock.loaiDa != null && rock.loaiDa!.trim().isNotEmpty) {
        if (seenLoaiDa.add(rock.loaiDa!.trim())) {
          uniqueList.add(rock);
        }
      }
    }
    return uniqueList;
  }

  Future<List<File>> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
    return pickedFiles.map((xfile) => File(xfile.path)).toList();
  }
}
