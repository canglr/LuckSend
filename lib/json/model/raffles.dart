class Raffles {
  String title;
  String id_share;

  Raffles({
    this.title,
    this.id_share,
  });

  factory Raffles.fromJson(Map<String, dynamic> json) {
    return Raffles(
      title: json['title'],
      id_share: json['id_share'],
    );
  }
}