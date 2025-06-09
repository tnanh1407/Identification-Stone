enum RockCategory {
  tatCa,
  bienChat,
  magma,
  tramTich,
  khac; // Thêm mục "Khác" để xử lý các nhóm đá không xác định

  // Tạo một getter để lấy tên hiển thị
  // Điều này giúp tách biệt logic khỏi giá trị enum thuần túy
  String get displayName {
    switch (this) {
      case RockCategory.tatCa:
        return 'Tất cả';
      case RockCategory.bienChat:
        return 'Biến chất';
      case RockCategory.magma:
        return 'Magma';
      case RockCategory.tramTich:
        return 'Trầm tích';
      case RockCategory.khac:
        return 'Khác';
    }
  }

  // Một hàm static để chuyển đổi từ String (dữ liệu từ Firebase) sang enum
  // Rất hữu ích và mạnh mẽ!
  static RockCategory fromString(String? value) {
    if (value == null) return RockCategory.khac;
    switch (value.toLowerCase()) {
      case 'biến chất':
        return RockCategory.bienChat;
      case 'magma':
        return RockCategory.magma;
      case 'trầm tích':
        return RockCategory.tramTich;
      default:
        return RockCategory.khac;
    }
  }
}
