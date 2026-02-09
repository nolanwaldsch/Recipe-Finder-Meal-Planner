class RecipeSummary {
  RecipeSummary({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final String imageUrl;

  factory RecipeSummary.fromJson(Map<String, dynamic> json) {
    return RecipeSummary(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      imageUrl: json['image'] as String? ?? '',
    );
  }
}
