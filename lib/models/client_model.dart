// Client Model - Hostel, Hospital, Function, Company
class ClientModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String type; // Hostel / Hospital / Function / Company
  final String createdAt;

  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.gstNumber,
    required this.type,
    required this.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'],
        address: json['address'],
        gstNumber: json['gstNumber'],
        type: json['type'] ?? 'Company',
        createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'gstNumber': gstNumber,
        'type': type,
        'createdAt': createdAt,
      };

  ClientModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? gstNumber,
    String? type,
    String? createdAt,
  }) =>
      ClientModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        gstNumber: gstNumber ?? this.gstNumber,
        type: type ?? this.type,
        createdAt: createdAt ?? this.createdAt,
      );
}

/// Supported client types
const List<String> clientTypes = [
  'Hostel',
  'Hospital',
  'Function',
  'Company',
  'Other',
];
