import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:rock_classifier/data/models/rock_models.dart';

class AiComparisonService {
  Future<String> getComparisonSummary(RockModels rock1, RockModels rock2) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('API Key không được tìm thấy. Hãy chắc chắn bạn đã tạo file .env');
    }

    // SỬA: Dùng tên model hợp lệ. 'gemini-1.5-flash-latest' rất phù hợp cho việc tóm tắt nhanh.
    final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);

    // THAY ĐỔI: Gọi hàm prompt siêu ngắn gọn mới
    final prompt = _buildSuperConcisePrompt(rock1, rock2);

    try {
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        return response.text!;
      } else {
        throw Exception('AI không trả về kết quả.');
      }
    } catch (e) {
      print('Lỗi khi gọi API Gemini: $e');
      throw Exception('Không thể kết nối đến dịch vụ AI. Vui lòng thử lại sau.');
    }
  }

  // =======================================================================
  // >> PROMPT MỚI: Siêu ngắn gọn, tập trung vào 5 gạch đầu dòng <<
  // =======================================================================
  String _buildSuperConcisePrompt(RockModels rock1, RockModels rock2) {
    String rock1Json = jsonEncode(rock1.toJson());
    String rock2Json = jsonEncode(rock2.toJson());

    return """
Bạn là một AI chuyên tóm tắt thông tin. Nhiệm vụ của bạn là chắt lọc những điểm so sánh quan trọng nhất giữa hai mẫu đá và trình bày chúng dưới dạng danh sách gạch đầu dòng ngắn gọn, dễ hiểu.

Dưới đây là dữ liệu về hai mẫu đá:

**Đá 1:**
$rock1Json

**Đá 2:**
$rock2Json

Hãy tạo một bản tóm tắt so sánh, giới hạn trong đúng **5 gạch đầu dòng**. Mỗi gạch đầu dòng phải tập trung vào một ý chính duy nhất theo cấu trúc gợi ý sau:

*   🤝 **Quan hệ:** Chúng có liên quan gì với nhau? (ví dụ: cùng là đá magma, một xâm nhập, một phun trào).
*   ✨ **Điểm chung:** Đặc điểm tương đồng nổi bật nhất là gì? (ví dụ: độ cứng cao, thành phần hóa học...).
*   🔥 **Khác biệt cốt lõi:** Sự khác biệt lớn nhất về cách hình thành là gì? (ví dụ: nguội chậm dưới lòng đất so với nguội nhanh trên bề mặt).
*   🎨 **Bề ngoài:** Sự khác biệt trên thể hiện ra vẻ ngoài (cấu trúc, màu sắc) như thế nào? (ví dụ: tinh thể lớn, màu sáng so với tinh thể nhỏ, màu tối).
*   🛠️ **Ứng dụng:** Mỗi loại thường được dùng để làm gì? (ví dụ: dùng để trang trí so với dùng trong xây dựng).

**Yêu cầu về định dạng:**
- Trả lời bằng **tiếng Việt**.
- Sử dụng định dạng **Markdown** với gạch đầu dòng (`*`).
- Dùng emoji ở đầu mỗi dòng như gợi ý.
- In đậm các thuật ngữ hoặc thông tin quan trọng.
""";
  }
}
