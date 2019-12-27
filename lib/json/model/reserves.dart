class Reserves {
  String name;
  String id_share;
  bool status;

  Reserves({
    this.name,
    this.id_share,
    this.status,
  });

  factory Reserves.fromJson(Map<String, dynamic> json) {
    return Reserves(
      name: json['name'],
      id_share: json['id_share'],
      status: json['status'],
    );
  }
}