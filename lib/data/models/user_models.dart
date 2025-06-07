import 'package:cloud_firestore/cloud_firestore.dart';

class UserModels {
  final String uid;
  final String? fullName;
  final String? address;
  final String email;
  final String? avatar;
  final String role;
  final DateTime createdAt;

  // Cải thiện 1: Constructor nên là const để tối ưu hiệu năng
  const UserModels({
    required this.uid,
    this.fullName,
    this.address,
    required this.email,
    this.avatar,
    required this.role,
    required this.createdAt,
  });

  // Cải thiện 2: Thêm các phương thức tiện ích `empty` và `isEmpty`

  /// Factory constructor để tạo một user rỗng.
  /// Hữu ích khi cần giá trị mặc định hoặc khởi tạo.
  static UserModels empty = UserModels(
    uid: '',
    email: '',
    fullName: null,
    address: null,
    avatar: null,
    role: 'User',
    createdAt: DateTime(0),
  );

  /// Getter để kiểm tra xem user có phải là một đối tượng rỗng không.
  bool get isEmpty => this == UserModels.empty;
  bool get isNotEmpty => this != UserModels.empty;

  /// Cải thiện 3: Xử lý `createdAt` an toàn hơn
  /// Đảm bảo rằng dù `createdAt` trong Firestore có bị lỗi hay null,
  /// app vẫn không bị crash.
  factory UserModels.fromJson(Map<String, dynamic> json) {
    // Lấy timestamp từ json
    final timestamp = json['createdAt'] as Timestamp?;

    return UserModels(
      // Gán giá trị mặc định an toàn nếu key không tồn tại
      uid: json['uid'] as String? ?? '',
      fullName: json['fullName'] as String?,
      address: json['address'] as String?,
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'User', // Mặc định là 'User' nếu không có
      // Chuyển đổi timestamp thành DateTime, nếu null thì dùng thời gian hiện tại
      createdAt: timestamp?.toDate() ?? DateTime.now(),
    );
  }

  /// Chuyển đổi đối tượng UserModels thành map để lưu vào Firestore
  /// Cải thiện 4: Chỉ bao gồm các trường cần thiết khi ghi vào Firestore
  /// Không cần phải ghi `uid` vào document data vì nó đã là ID của document.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid, // Vẫn nên có uid trong data để dễ truy vấn
      'fullName': fullName,
      'address': address,
      'email': email,
      'avatar': avatar,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

// Cách copyWith đơn giản hơn
  UserModels copyWith({
    String? uid,
    String? fullName,
    String? address,
    String? email,
    String? avatar,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModels(
      uid: uid ?? this.uid,
      fullName: fullName, // Bỏ `?? this.fullName`
      address: address, // Bỏ `?? this.address`
      email: email ?? this.email,
      avatar: avatar, // Bỏ `?? this.avatar`
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  } 
}
