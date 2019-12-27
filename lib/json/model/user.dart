class User {
  final String mail_adress;
  final String name;
  final String id_share;
  final String creation_date;
  final String last_update;

  User({this.mail_adress,this.name,this.id_share,this.creation_date,this.last_update});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      mail_adress: json['mail_adress'],
      name: json['name'],
      id_share: json['id_share'],
      creation_date: json['creation_date'],
      last_update: json['last_update'],
    );
  }
}