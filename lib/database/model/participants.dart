class Participants {
  int _id;
  int _raffle_id;
  String _participant;
  String _createdat;

  Participants(this._raffle_id, this._participant, this._createdat);

  Participants.map(dynamic obj) {
    this._id = obj['id'];
    this._raffle_id = obj['raffle_id'];
    this._participant = obj['participant'];
    this._createdat = obj['createdat'];
  }

  int get id => _id;
  int get raffle_id => _raffle_id;
  String get participant => _participant;
  String get createdat => _createdat;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['raffle_id'] = _raffle_id;
    map['participant'] = _participant;
    map['createdat'] = _createdat;

    return map;
  }

  Participants.fromMap(Map<String, dynamic> map) {
    _id = map['id'];
    _raffle_id = map['raffle_id'];
    _participant = map['participant'];
    _createdat = map['createdat'];
  }
}