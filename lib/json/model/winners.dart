class Winners {
  String name;
  String id_share;
  bool status;

  Winners({
    this.name,
    this.id_share,
    this.status,
  });

  factory Winners.fromJson(Map<String, dynamic> json) {
    return Winners(
      name: json['name'],
      id_share: json['id_share'],
      status: json['status'],
    );
  }
}