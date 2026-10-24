import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/shortage.dart';

class ShortagesScreen extends StatefulWidget {
  const ShortagesScreen({super.key});

  @override
  State<ShortagesScreen> createState() => _ShortagesScreenState();
}

class _ShortagesScreenState extends State<ShortagesScreen> {
  List<Shortage> _shortages = [];

  @override
  void initState() {
    super.initState();
    _refreshShortages();
  }

  Future<void> _refreshShortages() async {
    final list = await DatabaseHelper.instance.getAllShortages();
    setState(() => _shortages = list);
  }

  void _showAddDialog() {
    final itemController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل صنف ناقص'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemController,
              decoration: const InputDecoration(labelText: 'اسم الصنف/البضاعة'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (itemController.text.trim().isNotEmpty) {
                final sh = Shortage(
                  itemName: itemController.text.trim(),
                  notes: notesController.text.trim(),
                  date: DateTime.now().toString().split(' ')[0],
                );
                await DatabaseHelper.instance.insertShortage(sh);
                Navigator.pop(ctx);
                _refreshShortages();
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دفتر نواقص البضائع')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: _shortages.isEmpty
          ? const Center(child: Text('لا توجد نواقص مسجلة حالياً'))
          : ListView.builder(
              itemCount: _shortages.length,
              itemBuilder: (ctx, i) {
                final item = _shortages[i];
                return ListTile(
                  title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.notes ?? ''}\nالتاريخ: ${item.date}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                    onPressed: () async {
                      await DatabaseHelper.instance.deleteShortage(item.id!);
                      _refreshShortages();
                    },
                  ),
                );
              },
            ),
    );
  }
}
