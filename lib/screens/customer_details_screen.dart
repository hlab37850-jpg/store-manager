import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../helpers/database_helper.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;
  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  List<TransactionModel> _transactions = [];
  double _balance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    final txs = await DatabaseHelper.instance.getTransactionsForCustomer(widget.customer.id!);
    final bal = await DatabaseHelper.instance.getCustomerBalance(widget.customer.id!);
    setState(() {
      _transactions = txs;
      _balance = bal;
      _isLoading = false;
    });
  }

  void _showAddTransactionDialog(String type) {
    final amountController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == 'debt' ? 'تسجيل مبلغ (عليه / دين)' : 'تسجيل دفعة (له / سداد)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'البيان / التفاصيل (اختياري)'),
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
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                final tx = TransactionModel(
                  customerId: widget.customer.id!,
                  amount: amount,
                  type: type,
                  description: descController.text.trim(),
                  date: DateTime.now().toString().split('.')[0],
                );
                await DatabaseHelper.instance.insertTransaction(tx);
                Navigator.pop(ctx);
                _refreshData();
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
      appBar: AppBar(title: Text(widget.customer.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: _balance >= 0 ? Colors.red.shade50 : Colors.green.shade50,
                  child: Column(
                    children: [
                      const Text('إجمالي الحساب الحقيقي', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        '${_balance.abs().toStringAsFixed(2)} ${_balance >= 0 ? 'عليه (دين)' : 'له (مستحق)'}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _balance >= 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          onPressed: () => _showAddTransactionDialog('debt'),
                          icon: const Icon(Icons.add),
                          label: const Text('تسجيل عليه'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          onPressed: () => _showAddTransactionDialog('credit'),
                          icon: const Icon(Icons.remove),
                          label: const Text('تسجيل له / دفعة'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: _transactions.isEmpty
                      ? const Center(child: Text('لا توجد معاملات مسجلة بعد'))
                      : ListView.builder(
                          itemCount: _transactions.length,
                          itemBuilder: (ctx, i) {
                            final tx = _transactions[i];
                            final isDebt = tx.type == 'debt';
                            return ListTile(
                              leading: Icon(
                                isDebt ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isDebt ? Colors.red : Colors.green,
                              ),
                              title: Text('${tx.amount.toStringAsFixed(2)} - ${isDebt ? 'عليه' : 'له'}'),
                              subtitle: Text('${tx.description ?? 'بدون بيان'}\n${tx.date}'),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
