class ImageData {
  final String id;
  final String altDescription;
  final String imageUrl;

  ImageData({required this.id, required this.altDescription, required this.imageUrl});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: json['id'],
      altDescription: json['alt_description'],
      imageUrl: json['urls']['raw'],
    );
  }
}