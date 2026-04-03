enum ResourceCategory {
  journals,
  books,
  guidelines,
  aiResearch
}

class MedicalResource {
  final String id;
  final String title;
  final String source;
  final String summary;
  final String category;
  final String imageUrl;
  final bool isTrending;
  final String? url;

  MedicalResource({
    required this.id,
    required this.title,
    required this.source,
    required this.summary,
    required this.category,
    required this.imageUrl,
    this.isTrending = false,
    this.url,
  });

  factory MedicalResource.fromJson(Map<String, dynamic> json) {
    return MedicalResource(
      id: json['id'],
      title: json['title'],
      source: json['source'],
      summary: json['summary'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      isTrending: json['isTrending'] ?? false,
      url: json['url'],
    );
  }
}
