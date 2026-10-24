class TransactionModel {
  final int? id;
  final int customerId;
  final double amount;
  final String type;
  final String? description;
  final String date;

  TransactionModel({
    this.id,
    required this.customerId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      customerId: map['customer_id'],
      amount: (map['amount'] as num).toDouble(),
      type: map['type'],
      description: map['description'],
      date: map['date'],
    );
  }
}
