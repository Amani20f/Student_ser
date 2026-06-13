class RequestTypeModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final bool isActive;
  final String? targetRole;
  final double price;

  RequestTypeModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.isActive,
    this.targetRole,
    required this.price,
  });

  factory RequestTypeModel.fromJson(Map<String, dynamic> json) {
    return RequestTypeModel(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      isActive: json['is_active'] ?? true,
      targetRole: json['target_role'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
    );
  }
}
