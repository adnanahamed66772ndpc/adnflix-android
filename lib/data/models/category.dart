class Category {
  final String id;
  final String name;
  final String? slug;
  final int? sortOrder;

  Category({
    required this.id,
    required this.name,
    this.slug,
    this.sortOrder,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      sortOrder: (json['sortOrder'] is num) ? (json['sortOrder'] as num).toInt() : null,
    );
  }
}
