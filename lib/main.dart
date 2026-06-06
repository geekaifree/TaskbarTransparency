import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const TaskbarTransparencyApp());
class TaskbarTransparencyApp extends StatelessWidget {
  const TaskbarTransparencyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: '任务栏透明', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true, brightness: Brightness.light),
    darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true, brightness: Brightness.dark),
    home: const TaskbarHomePage());
}

class TaskbarHomePage extends StatefulWidget {
  const TaskbarHomePage({super.key});
  @override
  State<TaskbarHomePage> setState() => _TaskbarHomePageState();
}

class _TaskbarHomePageState extends State<TaskbarHomePage> {
  double _opacity = 0.8;
  String _effect = '透明';
  bool _blur = true;
  double _blurRadius = 10;
  Color _tintColor = Colors.black;
  double _tintOpacity = 0.3;
  final _effects = ['透明', '亚克力', '模糊', '纯色'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() { _opacity = p.getDouble('opacity') ?? 0.8; _blur = p.getBool('blur') ?? true; _blurRadius = p.getDouble('blurRadius') ?? 10; });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('opacity', _opacity); await p.setBool('blur', _blur); await p.setDouble('blurRadius', _blurRadius);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎨 任务栏透明'), centerTitle: true, actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() { _opacity = 1.0; _effect = '透明'; _blur = false; _save(); }), tooltip: '重置'),
      ]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        // 预览
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          const Text('预览效果', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(height: 200, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]), borderRadius: BorderRadius.circular(12)), child: Stack(children: [
            const Center(child: Text('桌面背景', style: TextStyle(color: Colors.white, fontSize: 18))),
            Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 48, color: _tintColor.withOpacity(_tintOpacity * _opacity), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.window, color: Colors.white, size: 20), const SizedBox(width: 16),
              const Icon(Icons.search, color: Colors.white, size: 20), const SizedBox(width: 16),
              const Icon(Icons.folder, color: Colors.white, size: 20), const SizedBox(width: 16),
              Text('透明度: ${(_opacity * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ]))),
          ])),
        ]))),
        const SizedBox(height: 16),
        // 透明度
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('透明度', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Slider(value: _opacity, onChanged: (v) { setState(() => _opacity = v); _save(); }),
          Text('${(_opacity * 100).toInt()}%', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]))),
        const SizedBox(height: 12),
        // 效果选择
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('效果类型', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: _effects.map((e) => ChoiceChip(label: Text(e), selected: _effect == e, onSelected: (_) => setState(() => _effect = e))).toList()),
        ]))),
        const SizedBox(height: 12),
        // 模糊设置
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SwitchListTile(title: const Text('启用模糊', style: TextStyle(fontWeight: FontWeight.bold)), value: _blur, onChanged: (v) { setState(() => _blur = v); _save(); }, contentPadding: EdgeInsets.zero),
          if (_blur) ...[const SizedBox(height: 8), Row(children: [const Text('模糊半径: '), Expanded(child: Slider(value: _blurRadius, min: 1, max: 30, onChanged: (v) { setState(() => _blurRadius = v); _save(); })), Text('${_blurRadius.toInt()}px')]),
        ]))),
        const SizedBox(height: 12),
        // 色调
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('色调颜色', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [Colors.black, Colors.white, Colors.blue, Colors.purple, Colors.teal, Colors.indigo].map((c) => GestureDetector(onTap: () => setState(() => _tintColor = c), child: Container(width: 36, height: 36, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: _tintColor == c ? Colors.amber : Colors.grey.shade300, width: _tintColor == c ? 3 : 1))))).toList()),
          const SizedBox(height: 12),
          Row(children: [const Text('色调强度: '), Expanded(child: Slider(value: _tintOpacity, onChanged: (v) => setState(() => _tintOpacity = v))), Text('${(_tintOpacity * 100).toInt()}%')]),
        ]))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { _save(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('设置已保存并应用'), behavior: SnackBarBehavior.floating)); }, icon: const Icon(Icons.check), label: const Text('应用设置'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
      ])),
    );
  }
}
