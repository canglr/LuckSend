class Results {
  int _id;
  int _raffle_id;
  int _status;
  String _participant;
  String _createdat;

  Results(this._raffle_id, this._status, this._participant, this._createdat);

  Results.map(dynamic obj) {
    this._id = obj['id'];
    this._raffle_id = obj['raffle_id'];
    this._status = obj['status'];
    this._participant = obj['participant'];
    this._createdat = obj['createdat'];
  }

  int get id => _id;
  int get raffle_id => _raffle_id;
  int get status => _status;
  String get participant => _participant;
  String get createdat => _createdat;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['raffle_id'] = _raffle_id;
    map['status'] = _status;
    map['participant'] = _participant;
    map['createdat'] = _createdat;

    return map;
  }

  Results.fromMap(Map<String, dynamic> map) {
    _id = map['id'];
    _raffle_id = map['raffle_id'];
    _status = map['status'];
    _participant = map['participant'];
    _createdat = map['createdat'];
  }
}