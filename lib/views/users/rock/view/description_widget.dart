// lib/views/users/rock/view/description_widget.dart

import 'package:flutter/material.dart';
import 'package:rock_classifier/data/models/rock_models.dart';

class Description extends StatelessWidget {
  final RockModels rock;

  const Description({Key? key, required this.rock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String moTa = rock.mieuTa ?? "";

    // Nếu không có mô tả, không hiển thị widget
    if (moTa.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/icon_des1.png', width: 30, height: 30), // Đảm bảo có ảnh này
                const SizedBox(width: 12),
                const Text('Mô tả', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF303A53))),
              ],
            ),
            const SizedBox(height: 16),
            Text(moTa, textAlign: TextAlign.justify, style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.75), height: 1.6)),
          ],
        ),
      ),
    );
  }
}
