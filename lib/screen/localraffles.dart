import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:cekilismobil/database/model/raffles.dart';
import 'package:cekilismobil/database/dbhelper.dart';
import 'package:cekilismobil/screen/localraffledetail.dart';
import 'package:cekilismobil/global_class/globalcode.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
class LocalRaffles extends StatefulWidget {
@override
_LocalRafflesState createState() => new _LocalRafflesState();

}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
var db = new DBHelper();
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

class _LocalRafflesState extends State<LocalRaffles> with RouteAware {
  List<Raffles> items = new List();

  @override
  void initState() {
    super.initState();
  }


void rafflelistrefresh()
{
  db.getAllRaffles().then((raffles) {
    setState(() {
      items.clear();
      raffles.forEach((raffle) {
        items.add(Raffles.fromMap(raffle));
      });
    });
  });
}


void raffleinputclear()
{
  raffle_name.text = "";
  raffle_description.text = "";
}


  Future<void> saveRaffle() async {
    if(_validateInputs()) {
      await db.saveRaffle(new Raffles(raffle_name.text, raffle_description.text , GlobalCode.datetimenow(), GlobalCode.datetimenow()));
      rafflelistrefresh();
      raffleinputclear();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));

    rafflelistrefresh();

  }

@override
Widget build(BuildContext context) {

  Widget _localnewraffleform = new Container
    (
    child: new Form(
    key: _formKey,
    autovalidate: _autoValidate,
    child: Card(
      child: Column(
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
    ),
    ),
    ));


  Widget raffleslist = new Container (
      child: ListView.builder(
          physics: PageScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, position) {
            return Card(
                child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.card_giftcard, color: Colors.white70),
                  title: Text(
                    '${items[position].name}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
                  onTap: () {
                    LocalRaffleDetail.raffleid = items[position].id;
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (
                                BuildContext context) => new LocalRaffleDetail(),
                                settings: RouteSettings(name: 'LocalRaffleDetail'),
                        ));

                  },
                ),
              ],
            ));
          }),
      );


  Widget body = new Column(
    // This makes each child fill the full width of the screen
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      _localnewraffleform,
      raffleslist
    ],
  );


return Scaffold(
backgroundColor: Color.fromRGBO(18, 18, 18, 1),
appBar: new AppBar(
title: new Text(GlobalCode.lang(context, 'My_sweepstakes')),
  actions: <Widget>[
    new IconButton(icon: const Icon(Icons.save), onPressed: (
        ) { saveRaffle(); })
  ],
),
  body: new SingleChildScrollView(
      child:body


),


);



}
}