import 'package:flutter/material.dart';
import 'helpers/database_helper.dart';
import 'models/customer.dart';
import 'screens/customer_details_screen.dart';
import 'screens/shortages_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StoreManagerApp());
}

class StoreManagerApp extends StatelessWidget {
  const StoreManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدير المحل والمستحقات',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Customer> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshCustomers();
  }

  Future<void> _refreshCustomers() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllCustomers();
    setState(() {
      _customers = data;
      _isLoading = false;
    });
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String type = 'customer';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة حساب جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم')),
              TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف')),
              Row(
                children: [
                  Radio<String>(value: 'customer', groupValue: type, onChanged: (val) => setDialogState(() => type = val!)),
                  const Text('عميل'),
                  Radio<String>(value: 'supplier', groupValue: type, onChanged: (val) => setDialogState(() => type = val!)),
                  const Text('مورد'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  final customer = Customer(name: nameController.text.trim(), phone: phoneController.text.trim(), type: type);
                  await DatabaseHelper.instance.insertCustomer(customer);
                  Navigator.pop(ctx);
                  _refreshCustomers();
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدير المحل والمستحقات الذكي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShortagesScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddCustomerDialog, child: const Icon(Icons.person_add)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customers.isEmpty
              ? const Center(child: Text('لا يوجد عملاء أو موردين مسجلين بعد'))
              : ListView.builder(
                  itemCount: _customers.length,
                  itemBuilder: (ctx, i) {
                    final customer = _customers[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(customer.name[0])),
                      title: Text(customer.name),
                      subtitle: Text('${customer.phone ?? 'بدون رقم'} (${customer.type == 'customer' ? 'عميل' : 'مورد'})'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerDetailsScreen(customer: customer))).then((_) => _refreshCustomers());
                      },
                    );
                  },
                ),
    );
  }
}
