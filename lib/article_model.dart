class ArticleModel {
  const ArticleModel({
    required this.judul,
    this.deskripsi,
    this.urlToImage,
  });

  final String judul;
  final String? deskripsi;
  final String? urlToImage;

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final title = json['title'];
    final description = json['description'];
    final imageUrl = json['urlToImage'];

    return ArticleModel(
      judul: title is String && title.trim().isNotEmpty
          ? title
          : 'Judul tidak tersedia',
      deskripsi: description is String && description.trim().isNotEmpty
          ? description
          : null,
      urlToImage: imageUrl is String && imageUrl.trim().isNotEmpty
          ? imageUrl
          : null,
    );
  }
}
