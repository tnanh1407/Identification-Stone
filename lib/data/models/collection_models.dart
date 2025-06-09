import 'dart:convert';

import 'package:flutter/material.dart';

// Sử dụng @immutable để đảm bảo lớp này không thể bị thay đổi sau khi tạo.
// Điều này giúp ngăn ngừa các lỗi không mong muốn trong ứng dụng.
@immutable
class CollectionModel {
  final String id; // Document ID trong subcollection
  final String? userId;
  final List<String> hinhAnh;
  final String? location;
  final String? note;
  final String? order;
  final String? rockId; // ID của RockModel liên quan
  final String? tenDa;
  final String createAt; // SỬA: Đổi tên từ `time` thành `createAt` cho nhất quán

  const CollectionModel({
    required this.id,
    this.userId,
    this.hinhAnh = const [], // SỬA: Cung cấp giá trị mặc định để tránh null
    this.location,
    this.note,
    this.order,
    this.rockId,
    this.tenDa,
    required this.createAt, // SỬA: Thay đổi tên tham số cho khớp với thuộc tính
  });

  // THÊM: Một thực thể rỗng để sử dụng khi cần giá trị khởi tạo.
  static final empty = CollectionModel(id: '', createAt: '');

  /// Phương thức chính để tạo một đối tượng từ Map (dữ liệu từ Firestore) và ID của document.
  /// Đây là cách làm được khuyến khích.
  factory CollectionModel.fromMap(String id, Map<String, dynamic> map) {
    return CollectionModel(
      id: id,
      userId: map['userId'] as String?, // Giữ nguyên kiểu dữ liệu
      hinhAnh: List<String>.from(map['hinhAnh'] ?? []),
      location: map['location'] as String?,
      note: map['note'] as String?,
      order: map['order'] as String?,
      // SỬA: Đảm bảo key nhất quán (snake_case trong DB, camelCase trong Dart)
      rockId: map['rock_id'] as String?,
      tenDa: map['tenDa'] as String?,
      // SỬA: Sử dụng 'createAt' thay vì 'time'
      createAt: map['createAt'] as String? ?? '',
    );
  }

  /// Factory để tạo từ một chuỗi JSON. Hữu ích khi truyền dữ liệu.
  /// Yêu cầu có cả `id` và `source` (chuỗi JSON)
  factory CollectionModel.fromJson(String id, String source) {
    return CollectionModel.fromMap(id, json.decode(source) as Map<String, dynamic>);
  }

  /// Chuyển đổi đối tượng thành một Map để lưu vào Firestore.
  Map<String, dynamic> toMap() {
    return {
      // SỬA: Không bao gồm 'id' vì nó là ID của document, không phải là một trường dữ liệu.
      'userId': userId,
      'hinhAnh': hinhAnh,
      'location': location,
      'note': note,
      'order': order,
      'rock_id': rockId, // Giữ snake_case cho nhất quán với DB
      'tenDa': tenDa,
      'createAt': createAt, // SỬA: Sử dụng 'createAt'
    };
  }

  /// Chuyển đổi đối tượng thành chuỗi JSON.
  String toJson() => json.encode(toMap());

  /// THÊM: Phương thức `copyWith` rất hữu ích.
  /// Nó cho phép bạn tạo một bản sao của đối tượng nhưng thay đổi một vài thuộc tính.
  /// Rất phổ biến trong quản lý state (Bloc, Riverpod, Provider).
  CollectionModel copyWith({
    String? id,
    String? userId,
    List<String>? hinhAnh,
    String? location,
    String? note,
    String? order,
    String? rockId,
    String? tenDa,
    String? createAt,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hinhAnh: hinhAnh ?? this.hinhAnh,
      location: location ?? this.location,
      note: note ?? this.note,
      order: order ?? this.order,
      rockId: rockId ?? this.rockId,
      tenDa: tenDa ?? this.tenDa,
      createAt: createAt ?? this.createAt,
    );
  }
}
