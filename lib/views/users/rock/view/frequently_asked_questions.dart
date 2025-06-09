// lib/views/users/rock/view/frequently_asked_questions.dart

import 'package:flutter/material.dart';
import 'package:rock_classifier/data/models/rock_models.dart';

class FrequentlyAskedQuestions extends StatefulWidget {
  final RockModels rock;

  const FrequentlyAskedQuestions({Key? key, required this.rock}) : super(key: key);

  @override
  _FrequentlyAskedQuestionsState createState() => _FrequentlyAskedQuestionsState();
}

class _FrequentlyAskedQuestionsState extends State<FrequentlyAskedQuestions> {
  late List<bool> _isExpandedList;

  @override
  void initState() {
    super.initState();
    _isExpandedList = List.generate(widget.rock.cauHoi.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> questions = widget.rock.cauHoi;
    final List<String> answers = widget.rock.traLoi;

    if (questions.isEmpty) {
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
                Image.asset('assets/icon_qes.png', width: 30, height: 30), // Đảm bảo có ảnh này
                const SizedBox(width: 12),
                const Text("Câu hỏi thường gặp", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF303A53))),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final answer = index < answers.length ? answers[index] : "Chưa có câu trả lời.";
                return _buildQuestionAnswer(question, answer, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionAnswer(String question, String answer, int index) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(question, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF303A53))),
        trailing: Icon(_isExpandedList[index] ? Icons.remove : Icons.add, color: Colors.grey.shade600),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpandedList[index] = expanded;
          });
        },
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(color: const Color(0xFF303A53).withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: Text(answer, textAlign: TextAlign.justify, style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.7), height: 1.5)),
          ),
        ],
      ),
    );
  }
}
