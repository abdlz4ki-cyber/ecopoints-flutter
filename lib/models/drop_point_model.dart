class DropPointModel {
  final int id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  DropPointModel({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.isActive = true,
  });

  factory DropPointModel.fromJson(Map<String, dynamic> json) {
    return DropPointModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
    };
  }
}
