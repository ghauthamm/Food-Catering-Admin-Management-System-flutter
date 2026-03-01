// Inventory / Raw Material Model
class InventoryModel {
  final String id;
  final String name;
  final String unit; // kg / litre / piece
  final double quantity;
  final double lowStockThreshold;
  final double? pricePerUnit;
  final String? category;
  final String lastUpdated;

  InventoryModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.lowStockThreshold,
    this.pricePerUnit,
    this.category,
    required this.lastUpdated,
  });

  /// Returns true if stock is below the threshold
  bool get isLowStock => quantity <= lowStockThreshold;

  factory InventoryModel.fromJson(Map<String, dynamic> json) => InventoryModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        unit: json['unit'] ?? 'kg',
        quantity: (json['quantity'] ?? 0).toDouble(),
        lowStockThreshold: (json['lowStockThreshold'] ?? 5).toDouble(),
        pricePerUnit: json['pricePerUnit'] != null
            ? (json['pricePerUnit']).toDouble()
            : null,
        category: json['category'],
        lastUpdated: json['lastUpdated'] ??
            DateTime.now().toIso8601String().split('T').first,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'quantity': quantity,
        'lowStockThreshold': lowStockThreshold,
        'pricePerUnit': pricePerUnit,
        'category': category,
        'lastUpdated': lastUpdated,
      };

  InventoryModel copyWith({
    String? id,
    String? name,
    String? unit,
    double? quantity,
    double? lowStockThreshold,
    double? pricePerUnit,
    String? category,
    String? lastUpdated,
  }) =>
      InventoryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        quantity: quantity ?? this.quantity,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        pricePerUnit: pricePerUnit ?? this.pricePerUnit,
        category: category ?? this.category,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}

const List<String> inventoryCategories = [
  'Vegetables',
  'Fruits',
  'Grains',
  'Dairy',
  'Meat',
  'Spices',
  'Oil & Fats',
  'Beverages',
  'Other',
];
