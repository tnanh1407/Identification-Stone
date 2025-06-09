// lib/views/users/rock/view/other_information_widget.dart

import 'package:flutter/material.dart';
import 'package:rock_classifier/data/models/rock_models.dart';

class OtherInformationWidget extends StatelessWidget {
  final RockModels rock;

  const OtherInformationWidget({Key? key, required this.rock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = {
      'Thành phần khoáng sản': rock.thanhPhanKhoangSan,
      'Công dụng': rock.congDung,
      'Nơi phân bố': rock.noiPhanBo,
      'Khoáng sản liên quan': rock.motSoKhoangSanLienQuan,
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
                Image.asset('assets/icon_ttk.png', width: 30, height: 30), // Đảm bảo có ảnh này
                const SizedBox(width: 12),
                const Text('Thông tin khác', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF303A53))),
              ],
            ),
            const SizedBox(height: 20),
            ...validData.entries.map((entry) => _buildItem(title: entry.key, value: entry.value!)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF303A53))),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(value, textAlign: TextAlign.justify, style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7), height: 1.5)),
          ),
        ],
      ),
    );
  }
}
