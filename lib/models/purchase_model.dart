// Purchase / Expense Model
class PurchaseModel {
  final String id;
  final String vendorName;
  final String itemName;
  final double quantity;
  final String unit; // kg / litre / piece
  final double price;
  final bool gstIncluded;
  final double? gstPercent;
  final String date;
  final String? category;
  final String? notes;

  PurchaseModel({
    required this.id,
    required this.vendorName,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.price,
    this.gstIncluded = false,
    this.gstPercent,
    required this.date,
    this.category,
    this.notes,
  });

  /// Total price excluding GST
  double get basePrice => price;

  /// GST Amount
  double get gstAmount =>
      gstIncluded ? (price * (gstPercent ?? 0) / 100) : 0;

  /// Total including GST
  double get totalPrice => price + gstAmount;

  factory PurchaseModel.fromJson(Map<String, dynamic> json) => PurchaseModel(
        id: json['id'] ?? '',
        vendorName: json['vendorName'] ?? '',
        itemName: json['itemName'] ?? '',
        quantity: (json['quantity'] ?? 0).toDouble(),
        unit: json['unit'] ?? 'kg',
        price: (json['price'] ?? 0).toDouble(),
        gstIncluded: json['gstIncluded'] ?? false,
        gstPercent: json['gstPercent'] != null
            ? (json['gstPercent']).toDouble()
            : null,
        date: json['date'] ?? DateTime.now().toIso8601String().split('T').first,
        category: json['category'],
        notes: json['notes'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'vendorName': vendorName,
        'itemName': itemName,
        'quantity': quantity,
        'unit': unit,
        'price': price,
        'gstIncluded': gstIncluded,
        'gstPercent': gstPercent,
        'date': date,
        'category': category,
        'notes': notes,
      };

  PurchaseModel copyWith({
    String? id,
    String? vendorName,
    String? itemName,
    double? quantity,
    String? unit,
    double? price,
    bool? gstIncluded,
    double? gstPercent,
    String? date,
    String? category,
    String? notes,
  }) =>
      PurchaseModel(
        id: id ?? this.id,
        vendorName: vendorName ?? this.vendorName,
        itemName: itemName ?? this.itemName,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        price: price ?? this.price,
        gstIncluded: gstIncluded ?? this.gstIncluded,
        gstPercent: gstPercent ?? this.gstPercent,
        date: date ?? this.date,
        category: category ?? this.category,
        notes: notes ?? this.notes,
      );
}

const List<String> purchaseUnits = ['kg', 'g', 'litre', 'ml', 'piece', 'box', 'packet'];
const List<String> purchaseCategories = [
  'Vegetables',
  'Fruits',
  'Grains',
  'Dairy',
  'Meat',
  'Spices',
  'Oil & Fats',
  'Utilities',
  'Other',
];
