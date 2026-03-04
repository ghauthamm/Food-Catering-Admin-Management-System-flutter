/// A single menu item (dish) with name and price.
class MenuItem {
  final String name;
  final double price;
  final String? category; // e.g. Starter, Main Course, Dessert, Beverage

  MenuItem({
    required this.name,
    required this.price,
    this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        name: json['name'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        category: json['category'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'category': category,
      };

  MenuItem copyWith({
    String? name,
    double? price,
    String? category,
  }) =>
      MenuItem(
        name: name ?? this.name,
        price: price ?? this.price,
        category: category ?? this.category,
      );
}

/// Day-wise menu: holds menu items for each day of the week.
class DayMenu {
  final String id;
  final String day; // Monday, Tuesday, ... Sunday
  final String mealType; // breakfast, lunch, dinner
  final List<MenuItem> items;
  final bool isActive;
  final String lastUpdated;

  DayMenu({
    required this.id,
    required this.day,
    required this.mealType,
    required this.items,
    this.isActive = true,
    required this.lastUpdated,
  });

  factory DayMenu.fromJson(Map<String, dynamic> json) => DayMenu(
        id: json['id'] ?? '',
        day: json['day'] ?? 'Monday',
        mealType: json['mealType'] ?? 'lunch',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        isActive: json['isActive'] ?? true,
        lastUpdated: json['lastUpdated'] ??
            DateTime.now().toIso8601String().split('T').first,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'mealType': mealType,
        'items': items.map((e) => e.toJson()).toList(),
        'isActive': isActive,
        'lastUpdated': lastUpdated,
      };

  DayMenu copyWith({
    String? id,
    String? day,
    String? mealType,
    List<MenuItem>? items,
    bool? isActive,
    String? lastUpdated,
  }) =>
      DayMenu(
        id: id ?? this.id,
        day: day ?? this.day,
        mealType: mealType ?? this.mealType,
        items: items ?? this.items,
        isActive: isActive ?? this.isActive,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}

const List<String> weekDays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> menuCategories = [
  'Starter',
  'Main Course',
  'Rice & Bread',
  'Dessert',
  'Beverage',
  'Other',
];
