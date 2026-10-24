class Shortage {
  final int? id;
  final String itemName;
  final String? notes;
  final String date;

  Shortage({
    this.id,
    required this.itemName,
    this.notes,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'notes': notes,
      'date': date,
    };
  }

  factory Shortage.fromMap(Map<String, dynamic> map) {
    return Shortage(
      id: map['id'],
      itemName: map['item_name'],
      notes: map['notes'],
      date: map['date'],
    );
  }
}
