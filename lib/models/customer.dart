class Customer {
  final int? id;
  final String name;
  final String? phone;
  final String type;

  Customer({
    this.id,
    required this.name,
    this.phone,
    this.type = 'customer',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'type': type,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      type: map['type'],
    );
  }
}
