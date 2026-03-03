// Order Item sub-model
class OrderItem {
  final String itemName;
  final int quantity;
  final double price;

  OrderItem({
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        itemName: json['itemName'] ?? '',
        quantity: json['quantity'] ?? 0,
        price: (json['price'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'quantity': quantity,
        'price': price,
      };

  OrderItem copyWith({
    String? itemName,
    int? quantity,
    double? price,
  }) =>
      OrderItem(
        itemName: itemName ?? this.itemName,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
      );
}

// Order Model
class OrderModel {
  final String id;
  final String clientId;
  final String clientName;
  final String mealType;
  final List<OrderItem> items;
  final double totalAmount;
  final String date;
  final String status; // pending / delivered / cancelled
  final String? notes;

  OrderModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    this.mealType = 'breakfast',
    required this.items,
    required this.totalAmount,
    required this.date,
    this.status = 'pending',
    this.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] ?? '',
        clientId: json['clientId'] ?? '',
        clientName: json['clientName'] ?? '',
        mealType: json['mealType'] ?? 'breakfast',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        date: json['date'] ?? DateTime.now().toIso8601String().split('T').first,
        status: json['status'] ?? 'pending',
        notes: json['notes'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'mealType': mealType,
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'date': date,
        'status': status,
        'notes': notes,
      };

  OrderModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? mealType,
    List<OrderItem>? items,
    double? totalAmount,
    String? date,
    String? status,
    String? notes,
  }) =>
      OrderModel(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        clientName: clientName ?? this.clientName,
        mealType: mealType ?? this.mealType,
        items: items ?? this.items,
        totalAmount: totalAmount ?? this.totalAmount,
        date: date ?? this.date,
        status: status ?? this.status,
        notes: notes ?? this.notes,
      );
}

const List<String> orderStatuses = ['pending', 'delivered', 'cancelled'];
      const List<String> mealTypes = ['breakfast', 'lunch', 'dinner'];
