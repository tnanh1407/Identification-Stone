import 'package:flutter/material.dart';
import 'package:rock_classifier/views/users/function/compare/rock_comparison_selection_screen.dart';
// import 'package:stonelens/ScannerScreen.dart';
// import 'package:stonelens/viewmodels/rock_image_recognizer.dart';
// import 'package:stonelens/views/home/rock_comparison_selection_screen.dart'; // Import file màn hình kết quả

class HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: Offset(0, 11),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/icon_logo.jpg',
                        cacheWidth: 200, // Tăng hiệu suất
                        cacheHeight: 200,
                        fit: BoxFit.cover),
                  ),
                ),
              ),
              SizedBox(width: 14),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Khởi đầu",
                      style: TextStyle(
                        color: Color(0xFFE57C3B),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1),
                    SizedBox(
                      width: 220,
                      child: Text(
                        "Nhận biết đá và thêm vào bộ sưu tập của bạn để nâng cấp tiến trình",
                        style: TextStyle(
                          color: Color(0xFFD0D3D4),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionButton(
                icon: Icons.camera_alt,
                text: "Nhận biết bằng hình ảnh",
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => ScannerScreen()),
                  // );
                },
              ),
              SizedBox(width: 20), // Thêm khoảng cách giữa hai nút
              ActionButton(
                icon: Icons.compare,
                text: "Phân biệt các loại đá",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RockFirstSelectionScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ActionButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95; // Nhấn xuống
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // Trở lại bình thường
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Material(
        color: Color(0xFFF7C873),
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.orangeAccent.withOpacity(0.3),
          highlightColor: Colors.orange.withOpacity(0.15),
          child: Container(
            width: 140,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: Colors.black, size: 28),
                SizedBox(height: 8),
                Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
