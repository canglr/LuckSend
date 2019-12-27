import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cekilismobil/database/dbhelper.dart';
import 'package:cekilismobil/database/model/raffles.dart';
import 'package:cekilismobil/global_class/globalcode.dart';



class LocalUpdateRaffle extends StatefulWidget {
  static var raffleid;
  @override
  _LocalUpdateRaffleState createState() => new _LocalUpdateRaffleState();
}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
bool _autoValidate = false;

var raffle_name = new TextEditingController();
var raffle_description = new TextEditingController();


bool _validateInputs() {
  if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
    _formKey.currentState.save();
    return true;
  } else {
    return false;
  }
}


Future<void> updateRaffle() async {
  if(_validateInputs()) {
    var db = new DBHelper();
    await db.updateRaffle(new Raffles(raffle_name.text, raffle_description.text, '', GlobalCode.datetimenow()),LocalUpdateRaffle.raffleid);
  }
}

Widget _localnewraffleform(BuildContext context)
{
  return Card( child: Column(
    children: <Widget>[
      new ListTile(
        leading: const Icon(Icons.card_giftcard, color: Colors.white70),
        title: new TextFormField(
          maxLength: 60,
          validator: (value) {
            value = value.trim();
            if (value.isEmpty) {
              return GlobalCode.lang(context, 'Cannot_be_empty');
            }
          },
        controller: raffle_name,
          decoration: new InputDecoration(
            hintText: GlobalCode.lang(context, 'Raffle_Name'),
          ),
        ),
      ),
      new ListTile(
        leading: const Icon(Icons.description, color: Colors.white70),
        title: new TextFormField(
          maxLength: 180,
          controller: raffle_description,
          decoration: new InputDecoration(
            hintText: GlobalCode.lang(context, 'Description'),
          ),
        ),
      ),

    ],
  ));
}


class _LocalUpdateRaffleState extends State<LocalUpdateRaffle> {

  var db = new DBHelper();

  void raffleget()
  {
    db.detailRaffle(LocalUpdateRaffle.raffleid).then((raffles) {
      setState(() {
        raffles.forEach((raffle) {
          raffle_name.text = raffle["name"];
          raffle_description.text = raffle["description"];
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    raffleget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: new AppBar(
        title: new Text(GlobalCode.lang(context, 'Update_Raffle')),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.save), onPressed: (
              ) {
              updateRaffle();
              Navigator.pop(context,false);
          })
        ],
      ),

      body:
      new SingleChildScrollView(
      child: new Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: _localnewraffleform(context),
      ),
      ),


    );
  }


}