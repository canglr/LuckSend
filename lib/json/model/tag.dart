class Tag {
  String tag_name;
  int id;

  Tag({
    this.tag_name,
    this.id,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tag_name: json['tag_name'],
      id: json['id'],
    );
  }
}