class SocialRafflesModel {
  String author_name;
  String id_share;
  String media_image;
  bool sponsor;
  bool type;

  SocialRafflesModel({
    this.author_name,
    this.id_share,
    this.media_image,
    this.sponsor,
    this.type,
  });

  factory SocialRafflesModel.fromJson(Map<String, dynamic> json) {
    return SocialRafflesModel(
      author_name: json['author_name'],
      id_share: json['id_share'],
      media_image: json['media_image'],
      sponsor: json['sponsor'],
      type: json['type'],
    );
  }
}