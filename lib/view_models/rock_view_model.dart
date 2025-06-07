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

  List<RockModels> _originalRocks = [];
  List<RockModels> _rocks = [];
  List<RockModels> get rocks => _rocks;

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

  Future<void> fetchRocks() async {
    _setLoading(true);
    try {
      _originalRocks = await _service.fetchAllRocks();
      _rocks = List.from(_originalRocks);
    } catch (e) {
      debugPrint("Lỗi fetchRocks: $e");
      _originalRocks = [];
      _rocks = [];
    } finally {
      _setLoading(false);
    }
  }

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
      await _service.addRock(rockWithImages); // Service sẽ tự gán UID
      await fetchRocks();
    } catch (e) {
      debugPrint("Lỗi addRock: $e");
      rethrow;
    } finally {
      _setUpdating(false);
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

  void searchRocks(String query) {
    if (query.isEmpty) {
      _rocks = List.from(_originalRocks);
    } else {
      final lowerCaseQuery = query.toLowerCase();
      _rocks = _originalRocks.where((rock) {
        return (rock.tenDa?.toLowerCase().contains(lowerCaseQuery) ?? false) || (rock.loaiDa?.toLowerCase().contains(lowerCaseQuery) ?? false);
      }).toList();
    }
    notifyListeners();
  }

  void sortRocks(RockSortOption option) {
    switch (option) {
      case RockSortOption.tenDa:
        _rocks.sort((a, b) => (a.tenDa ?? '').compareTo(b.tenDa ?? ''));
        break;
      case RockSortOption.loaiDa:
        _rocks.sort((a, b) => (a.loaiDa ?? '').compareTo(b.loaiDa ?? ''));
        break;
      case RockSortOption.nhomDa:
        _rocks.sort((a, b) => (a.nhomDa ?? '').compareTo(b.nhomDa ?? ''));
        break;
    }
    notifyListeners();
  }

  Future<List<File>> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
    return pickedFiles.map((xfile) => File(xfile.path)).toList();
  }
}
