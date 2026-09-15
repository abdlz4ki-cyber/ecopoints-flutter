class RewardModel {
  final int id;
  final String name;
  final String? description;
  final int pointCost;
  final int stock;
  final String? image;
  final bool isActive;

  RewardModel({
    required this.id,
    required this.name,
    this.description,
    required this.pointCost,
    required this.stock,
    this.image,
    this.isActive = true,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      pointCost: json['point_cost'] is int
          ? json['point_cost']
          : int.tryParse(json['point_cost']?.toString() ?? '0') ?? 0,
      stock: json['stock'] is int
          ? json['stock']
          : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      image: json['image']?.toString(),
      isActive: json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'point_cost': pointCost,
      'stock': stock,
      'image': image,
      'is_active': isActive,
    };
  }
}
