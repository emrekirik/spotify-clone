class Category {
  final String id;
  final String name;
  final String imageURL;

  Category({
    required this.id,
    required this.name,
    required this.imageURL,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      imageURL: json['icons'][0]['url'],
    );
  }
}
