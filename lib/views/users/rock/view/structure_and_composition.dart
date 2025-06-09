// lib/views/users/rock/view/structure_and_composition.dart

import 'package:flutter/material.dart';
import 'package:rock_classifier/data/models/rock_models.dart';

class StructureAndComposition extends StatelessWidget {
  final RockModels rock;

  const StructureAndComposition({Key? key, required this.rock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String kienTruc = rock.kienTruc ?? "";
    final String cauTao = rock.cauTao ?? "";

    if (kienTruc.isEmpty && cauTao.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/connection.png', width: 30, height: 30), // Đảm bảo có ảnh này
                const SizedBox(width: 12),
                const Text("Kiến trúc và Cấu tạo", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF303A53))),
              ],
            ),
            const SizedBox(height: 20),
            if (kienTruc.isNotEmpty) ...[
              _buildInfoRow('Kiến trúc', kienTruc, Colors.deepOrange),
              const SizedBox(height: 16),
            ],
            if (cauTao.isNotEmpty) ...[
              _buildInfoRow('Cấu tạo', cauTao, Colors.teal),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String description, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF303A53).withOpacity(0.9))),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(description, textAlign: TextAlign.justify, style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7), height: 1.5)),
        ),
      ],
    );
  }
}
