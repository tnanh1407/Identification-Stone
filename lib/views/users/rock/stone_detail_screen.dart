// lib/views/users/rock/stone_detail_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ===========================================================================
// >> BƯỚC 1: KIỂM TRA VÀ SỬA CÁC ĐƯỜNG DẪN IMPORT NÀY <<
// ===========================================================================
import 'package:rock_classifier/data/models/rock_models.dart';
import 'package:rock_classifier/data/services/favorite_service.dart';
import 'package:rock_classifier/views/users/rock/view/Description_widget.dart';
import 'package:rock_classifier/views/users/rock/view/basic_characteristics.dart';
import 'package:rock_classifier/views/users/rock/view/frequently_asked_questions.dart';
import 'package:rock_classifier/views/users/rock/view/other_information_widget.dart';
import 'package:rock_classifier/views/users/rock/view/stone_info_widget.dart';
import 'package:rock_classifier/views/users/rock/view/structure_and_composition.dart';

// Các màn hình khác (bỏ comment và chỉnh sửa đường dẫn nếu cần)
// import 'package:stonelens/ScannerScreen.dart';
// import 'package:stonelens/views/colection/add_colection.dart';
// ===========================================================================

// --- CollectionService ---
// Service này quản lý việc một viên đá có nằm trong bộ sưu tập của người dùng hay không.
class CollectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<bool> checkRockInUserCollection(String rockUid) {
    final userId = _auth.currentUser?.uid;
    if (rockUid.isEmpty || userId == null) {
      return Stream.value(false);
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('collections')
        .where('rock_id', isEqualTo: rockUid) // Giả sử trường trong DB là 'rock_id'
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty)
        .handleError((_) => false);
  }
}

// --- Màn hình chính: StoneDetailScreen ---
class StoneDetailScreen extends StatefulWidget {
  final RockModels? rock; // Dữ liệu đá từ danh sách có sẵn
  final String? stoneData; // Dữ liệu đá dạng JSON từ kết quả AI

  const StoneDetailScreen({Key? key, this.rock, this.stoneData}) : super(key: key);

  @override
  _StoneDetailScreenState createState() => _StoneDetailScreenState();
}

class _StoneDetailScreenState extends State<StoneDetailScreen> {
  // Khởi tạo các service cần thiết
  final FavoriteService _favoriteService = FavoriteService();
  final CollectionService _collectionService = CollectionService();

  // Đối tượng RockModels sẽ được sử dụng trong toàn bộ màn hình
  late final RockModels rock;

  @override
  void initState() {
    super.initState();
    // Logic xác định nguồn dữ liệu: từ JSON của AI hay từ đối tượng RockModels có sẵn
    if (widget.stoneData != null && widget.stoneData!.isNotEmpty) {
      try {
        final Map<String, dynamic> parsedJson = jsonDecode(widget.stoneData!);
        rock = RockModels.fromJson(parsedJson);
      } catch (e) {
        debugPrint("Lỗi parse JSON trong StoneDetailScreen: $e");
        rock = RockModels.empty; // Gán đối tượng rỗng nếu lỗi
      }
    } else if (widget.rock != null) {
      rock = widget.rock!;
    } else {
      // Trường hợp không có dữ liệu đầu vào -> Gán đối tượng rỗng để tránh lỗi
      rock = RockModels.empty;
    }
  }

  // Hàm xử lý việc thêm/xóa khỏi danh sách yêu thích
  void _toggleFavorite(bool isCurrentlyFavorite) async {
    if (rock.uid.isNotEmpty) {
      await _favoriteService.toggleFavorite(rock.uid, isCurrentlyFavorite);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu không có dữ liệu đá hợp lệ, hiển thị màn hình lỗi
    if (rock.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Lỗi")),
        body: const Center(child: Text("Không tìm thấy dữ liệu đá.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền nhẹ nhàng, dễ chịu
      extendBodyBehindAppBar: true, // Cho phép body nằm sau AppBar
      extendBody: true, // Cho phép body nằm sau BottomNavBar
      // Sử dụng CustomScrollView để tạo hiệu ứng AppBar co giãn (collapsing app bar)
      body: CustomScrollView(
        slivers: [
          // Phần AppBar co giãn với ảnh nền
          SliverAppBar(
            expandedHeight: 280.0, // Chiều cao khi mở rộng tối đa
            pinned: true, // Ghim AppBar lại khi cuộn lên
            stretch: true, // Hiệu ứng kéo dãn khi cuộn quá
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'stoneImage_${rock.uid}', // Tag duy nhất cho Hero animation
                child: Image.network(
                  rock.hinhAnh.isNotEmpty ? rock.hinhAnh[0] : 'https://via.placeholder.com/400x250?text=No+Image',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset('assets/placeholder.png', fit: BoxFit.cover),
                ),
              ),
            ),
          ),

          // Phần nội dung có thể cuộn
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[50], // Đảm bảo nền đồng nhất
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần Tên đá, loại đá và nút Yêu thích
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 8, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
// Đoạn code mới đã được chỉnh sửa
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sử dụng RichText để có thể định dạng nhiều kiểu chữ trên một dòng
                              RichText(
                                text: TextSpan(
                                  // Style mặc định cho toàn bộ RichText (nếu cần)
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF303A53),
                                    height: 1.3, // Tăng khoảng cách dòng để dễ đọc hơn
                                  ),
                                  children: [
                                    // Phần 1: Tên đá (tên khoa học)
                                    TextSpan(
                                      text: rock.tenDa ?? 'Chưa có tên',
                                    ),

                                    // Phần 2: Tên tiếng Việt (chỉ hiển thị nếu có)
                                    // Kiểm tra xem tenTiengViet có tồn tại và không phải là chuỗi rỗng
                                    if (rock.tenTiengViet != null && rock.tenTiengViet!.isNotEmpty)
                                      TextSpan(
                                        // Thêm khoảng trắng và dấu ngoặc đơn
                                        text: ' (${rock.tenTiengViet})',
                                        style: TextStyle(
                                          fontSize: 22, // Kích thước nhỏ hơn một chút
                                          fontWeight: FontWeight.w500, // Độ đậm vừa phải
                                          fontStyle: FontStyle.italic, // In nghiêng
                                          color: Colors.black.withOpacity(0.6), // Màu xám hơn
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Giữ nguyên phần hiển thị loại đá
                              Text(
                                'Loại đá: ${rock.loaiDa ?? 'Không rõ'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFE57C3B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Nút yêu thích với StreamBuilder
                        StreamBuilder<bool>(
                          stream: _favoriteService.rockFavoriteStatusStream(rock.uid),
                          builder: (context, snapshot) {
                            final isFavorite = snapshot.data ?? false;
                            return IconButton(
                              padding: const EdgeInsets.all(12),
                              onPressed: () => _toggleFavorite(isFavorite),
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  key: ValueKey<bool>(isFavorite),
                                  color: isFavorite ? Colors.red : Colors.grey.shade600,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // ==============================================================
                  // >> GỌI CÁC WIDGET CON MỘT CÁCH SẠCH SẼ VÀ ĐƠN GIẢN <<
                  // ==============================================================
                  StoneInfoWidget(rock: rock),
                  Description(rock: rock),
                  BasicCharacteristics(rock: rock),
                  StructureAndComposition(rock: rock),
                  FrequentlyAskedQuestions(rock: rock),
                  OtherInformationWidget(rock: rock),
                  // ==============================================================

                  // Khoảng trống ở dưới để không bị BottomNavBar che mất
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      // Thanh điều hướng ở dưới cùng
      bottomNavigationBar: BottomNavBar(
        rock: rock,
        favoriteService: _favoriteService,
        collectionService: _collectionService,
      ),
    );
  }
}

// --- BottomNavBar ---
// Widget này không cần thay đổi. Nó đã được thiết kế tốt.
class BottomNavBar extends StatelessWidget {
  final RockModels rock;
  final FavoriteService favoriteService;
  final CollectionService collectionService;

  const BottomNavBar({
    Key? key,
    required this.rock,
    required this.favoriteService,
    required this.collectionService,
  }) : super(key: key);

  void _toggleFavorite(BuildContext context, bool currentStatus) {
    if (rock.uid.isNotEmpty) {
      favoriteService.toggleFavorite(rock.uid, currentStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: favoriteService.rockFavoriteStatusStream(rock.uid),
      builder: (context, favoriteSnapshot) {
        final isFavorite = favoriteSnapshot.data ?? false;
        final width = MediaQuery.of(context).size.width;

        return StreamBuilder<bool>(
          stream: collectionService.checkRockInUserCollection(rock.uid),
          builder: (context, collectionSnapshot) {
            final isInCollection = collectionSnapshot.data ?? false;

            return Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Camera Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => ScannerScreen()));
                          },
                          child: _buildIconButton(icon: Icons.camera_alt_outlined),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Favorite Button
                      GestureDetector(
                        onTap: () => _toggleFavorite(context, isFavorite),
                        child: _buildIconButton(
                          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                          iconColor: isFavorite ? Colors.redAccent : Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // Button Thêm vào bộ sưu tập
                  SizedBox(
                    width: width * 0.55,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isInCollection
                          ? null
                          : () {
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => CollectionDetailScreen(rock: rock)));
                            },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        elevation: 0,
                        backgroundColor: Colors.transparent, // Để Ink trang trí
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: isInCollection
                              ? null
                              : const LinearGradient(
                                  colors: [Color(0xFFFFB547), Color(0xFFF37736)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                          color: isInCollection ? Colors.grey[300] : null,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isInCollection ? Icons.check_circle_outline : Icons.add_circle_outline,
                                color: isInCollection ? Colors.grey[700] : Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isInCollection ? "Đã có trong bộ sưu tập" : "Thêm vào bộ sưu tập",
                                style: TextStyle(
                                  color: isInCollection ? Colors.grey[700] : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper để xây dựng các icon button nhỏ
  Widget _buildIconButton({required IconData icon, Color iconColor = Colors.black}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }
}
