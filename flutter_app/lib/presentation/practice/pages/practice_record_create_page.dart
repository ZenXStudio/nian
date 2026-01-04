import 'package:flutter/material.dart';
import 'package:mental_app/presentation/widgets/app_button.dart';
import 'package:mental_app/presentation/widgets/app_text_field.dart';

/// 练习记录创建页面（占位）
class PracticeRecordCreatePage extends StatefulWidget {
  const PracticeRecordCreatePage({super.key});

  @override
  State<PracticeRecordCreatePage> createState() => _PracticeRecordCreatePageState();
}

class _PracticeRecordCreatePageState extends State<PracticeRecordCreatePage> {
  final _formKey = GlobalKey<FormState>();
  int _beforeMood = 5;
  int _afterMood = 5;
  int _duration = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录练习'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 选择方法
            const Text(
              '选择方法',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '请选择练习方法',
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('深呼吸练习')),
                DropdownMenuItem(value: '2', child: Text('正念冥想')),
                DropdownMenuItem(value: '3', child: Text('渐进式放松')),
              ],
              onChanged: (value) {},
            ),

            const SizedBox(height: 24),

            // 练习时长
            const Text(
              '练习时长（分钟）',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _duration.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              label: '$_duration 分钟',
              onChanged: (value) {
                setState(() {
                  _duration = value.toInt();
                });
              },
            ),
            Text(
              '$_duration 分钟',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // 练习前状态
            const Text(
              '练习前心理状态',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildMoodSlider(_beforeMood, (value) {
              setState(() {
                _beforeMood = value;
              });
            }),

            const SizedBox(height: 24),

            // 练习后状态
            const Text(
              '练习后心理状态',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildMoodSlider(_afterMood, (value) {
              setState(() {
                _afterMood = value;
              });
            }),

            const SizedBox(height: 24),

            // 备注
            const Text(
              '备注（可选）',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '记录你的感受和想法...',
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // 提交按钮
            ElevatedButton(
              onPressed: _submitPractice,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '保存记录',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建心情滑块
  Widget _buildMoodSlider(int value, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: value.toString(),
          onChanged: (v) => onChanged(v.toInt()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('很差', style: TextStyle(color: Colors.grey[600])),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getMoodColor(value),
              ),
            ),
            Text('很好', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  /// 根据评分获取颜色
  Color _getMoodColor(int value) {
    if (value <= 3) return Colors.red;
    if (value <= 6) return Colors.orange;
    return Colors.green;
  }

  /// 提交练习记录
  void _submitPractice() {
    // TODO: 提交到后端
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('练习记录已保存')),
    );
    Navigator.pop(context);
  }
}
