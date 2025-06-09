// lib/views/users/rock/view/basic_characteristics.dart

import 'package:flutter/material.dart';
import 'package:rock_classifier/data/models/rock_models.dart';

class BasicCharacteristics extends StatelessWidget {
  final RockModels rock;

  const BasicCharacteristics({Key? key, required this.rock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = {
      'Công thức hóa học': rock.thanhPhanHoaHoc,
      'Độ cứng': rock.doCung,
      'Màu sắc': rock.mauSac,
      'Mật độ': rock.matDo,
    };

    final validData = Map.fromEntries(data.entries.where((entry) => entry.value != null && entry.value!.isNotEmpty));

    if (validData.isEmpty) {
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
                Image.asset('assets/icon_basic.png', width: 28, height: 28), // Đảm bảo có ảnh này
                const SizedBox(width: 12),
                const Text("Đặc điểm cơ bản", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF303A53))),
              ],
            ),
            const SizedBox(height: 20),
            ...validData.entries.map((entry) => _buildInfoRow(entry.key, entry.value!)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 140, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87))),
              const SizedBox(width: 8),
              Expanded(child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black54))),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
        ],
      ),
    );
  }
}
