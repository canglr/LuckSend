class Raffles {
  int _id;
  String _name;
  String _description;
  String _createdat;
  String _updatedat;

  Raffles(this._name, this._description, this._createdat, this._updatedat);

  Raffles.map(dynamic obj) {
    this._id = obj['id'];
    this._name = obj['name'];
    this._description = obj['description'];
    this._createdat = obj['createdat'];
    this._updatedat = obj['updatedat'];
  }

  int get id => _id;
  String get name => _name;
  String get description => _description;
  String get createdat => _createdat;
  String get updatedat => _updatedat;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    if (_name != '') {
      map['name'] = _name;
    }
    if (_description != '') {
      map['description'] = _description;
    }
    if (_createdat != '') {
      map['createdat'] = _createdat;
    }
    if (_updatedat != '') {
      map['updatedat'] = _updatedat;
    }

    return map;
  }

  Raffles.fromMap(Map<String, dynamic> map) {
    _id = map['id'];
    _name = map['name'];
    _description = map['description'];
    _createdat = map['createdat'];
    _updatedat = map['updatedat'];
  }
}