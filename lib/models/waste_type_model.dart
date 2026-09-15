class WasteTypeModel {
  final int id;
  final String name;
  final double unitPricePerKg;
  final int pointsPerKg;
  final String? description;
  final bool isActive;

  WasteTypeModel({
    required this.id,
    required this.name,
    required this.unitPricePerKg,
    required this.pointsPerKg,
    this.description,
    this.isActive = true,
  });

  factory WasteTypeModel.fromJson(Map<String, dynamic> json) {
    return WasteTypeModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      unitPricePerKg: (json['unit_price_per_kg'] is num)
          ? (json['unit_price_per_kg'] as num).toDouble()
          : double.tryParse(json['unit_price_per_kg']?.toString() ?? '0') ??
              0.0,
      pointsPerKg: json['points_per_kg'] is int
          ? json['points_per_kg']
          : int.tryParse(json['points_per_kg']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString(),
      isActive: json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit_price_per_kg': unitPricePerKg,
      'points_per_kg': pointsPerKg,
      'description': description,
      'is_active': isActive,
    };
  }
}
